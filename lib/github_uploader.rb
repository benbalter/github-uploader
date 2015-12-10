require 'octokit'
require 'sinatra_auth_github'
require 'dotenv'
require 'open3'
require 'json'
require 'securerandom'
require 'fileutils'
require 'rack/coffee'
require_relative "github_uploader/helpers"

Dotenv.load

module GitHubUploader
  class App < Sinatra::Base

    include GitHubUploader::Helpers

    configure :production do
      require 'rack-ssl-enforcer'
      use Rack::SslEnforcer
    end

    if ENV["REDIS_URL"] && !ENV["REDIS_URL"].to_s.empty?
      use Rack::Session::Moneta, store: :Redis, url: ENV["REDIS_URL"]
    else
      use Rack::Session::Cookie, {
        :http_only => true,
        :secret    => ENV['SESSION_SECRET'] || SecureRandom.hex
      }
    end

    set :github_options, { :scopes => "repo" }
    ENV['WARDEN_GITHUB_VERIFIER_SECRET'] ||= SecureRandom.hex
    register Sinatra::Auth::Github

    configure do
      Octokit.auto_paginate = true
    end

    before do
      authenticate!
    end

    use Rack::Coffee, root: "#{root}/public", urls: '/assets/javascripts'

    get "/" do
      render_template :index, { :repositories => client.repositories }
    end

    get "/:user/:repo/?*" do
      render_template :tree, {
        :tree => tree(path),
        :nwo  => nwo,
        :path => path,
        :repo => repo,
        :msg  => nil
      }
    end

    post "/:user/:repo/?*" do
      params['path'] = params['doc'][:tempfile].path
      params['filename'] = File.basename params['doc'][:filename]
      cache_params
      authenticate!

      if process_upload
        msg = "\"#{params['filename']}\" uploaded successfully"
      else
        msg = "FAILED"
      end

      render_template :tree, {
        :tree => tree(path),
        :nwo  => nwo,
        :path => path,
        :repo => repo,
        :msg  => msg
      }
    end
  end
end
