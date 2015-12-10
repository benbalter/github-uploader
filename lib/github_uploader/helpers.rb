module GitHubUploader
  module Helpers
    def root
      @root ||= File.expand_path "../", File.dirname(__FILE__)
    end

    def client
      @client ||= Octokit::Client.new :access_token => github_user.token
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

    def path
      params[:splat].first.to_s
    end

    def process_upload
      upload "#{path}/#{params['filename']}", "Upload #{params['filename']}", params['path']
    end
  end
end
