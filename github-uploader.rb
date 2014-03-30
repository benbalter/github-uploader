require 'octokit'
require 'sinatra_auth_github'
require 'dotenv'
require 'open3'
require 'json'
require 'securerandom'
require 'fileutils'
require 'rack/coffee'

Dotenv.load

class GitHubUploader
  class App < Sinatra::Base

    enable :sessions

    set :github_options, {
      :scopes    => "repo",
      :secret    => ENV['GITHUB_CLIENT_SECRET'],
      :client_id => ENV['GITHUB_CLIENT_ID'],
    }

    register Sinatra::Auth::Github
    Octokit.auto_paginate = true
    use Rack::Coffee, root: 'public', urls: '/assets/javascripts'

    use Rack::Session::Cookie, {
      :http_only => true,
      :secret => ENV['SESSION_SECRET'] || SecureRandom.hex
    }

    configure :production do
      require 'rack-ssl-enforcer'
      use Rack::SslEnforcer
    end

    def root
      @root ||= File.expand_path File.dirname(__FILE__)
    end

    def user
      env['warden'].user
    end

    def client
      @client ||= Octokit::Client.new :access_token => user.token
    end

    def repo
      @repo ||= client.repository "#{params[:user]}/#{params[:repo]}"
    end

    def nwo
      @nwo ||= "#{repo.owner.login}/#{repo.name}"
    end

    def render_template(template, locals)
      halt erb template, :layout => :layout, :locals => locals.merge(:template => template)
    end

    def tree(path=nil)
      client.contents nwo, path: path
    end

    def cache_params
      session[:params] = params.to_json
    end

    def uncache_params
      params.merge! JSON.parse(session.delete(:params))
    end

    def file_exists?(path)
      directory = File.dirname path
      filename = File.basename path
      tree(directory).any? { |object| object.path == filename }
    end

    def upload(upload_path, message, file)
      if file_exists?(upload_path)
        blob = client.contents nwo, path: upload_path
        client.update_contents nwo, upload_path, message, blob.sha, file: file
      else
        client.create_contents nwo, upload_path, message, file: file
      end
    end

    get "/" do
      authenticate!
      render_template :index, { :repositories => client.repositories }
    end

    get "/:user/:repo/?*" do
      authenticate!
      path = params[:splat].first.to_s
      if session[:params]
        uncache_params
        upload "#{path}/#{params['filename']}", "Upload #{params['filename']}", params['path']
        msg = "\"#{params['filename']}\" uploaded successfully"
      end
      render_template :tree, { :tree => tree(path), :nwo => nwo, :path => path, :repo => repo, :msg => msg }
    end

    post "/:user/:repo/?*" do
      params['path'] = params['doc'][:tempfile].path
      params['filename'] = File.basename params['doc'][:filename]
      cache_params
      authenticate!
    end
  end
end
