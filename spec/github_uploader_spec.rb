require "spec_helper"

describe GitHubUploader do
  describe "logged out user" do
    include Rack::Test::Methods

    def app
      GitHubUploader::App
    end

    it "asks the user to log in from root" do
      get "/"
      expect(last_response.status).to eql(302)
      expect(last_response.headers['Location']).to match(%r{^https://github\.com/login/oauth/authorize})
    end

    it "asks the user to log in from a tree" do
      get "/benbalter/github-uploader/"
      expect(last_response.status).to eql(302)
      expect(last_response.headers['Location']).to match(%r{^https://github\.com/login/oauth/authorize})
    end

    it "asks the user to log in on upload" do
      post "/benbalter/github-uploader/"
      expect(last_response.status).to eql(302)
      expect(last_response.headers['Location']).to match(%r{^https://github\.com/login/oauth/authorize})
    end
  end

  describe "logged in user" do
    include Rack::Test::Methods

    def app
      GitHubUploader::App
    end

    before(:each) do
      @user = make_user('login' => 'benbaltertest')
      login_as @user
    end

    before do
      stub_request(:get, "https://api.github.com/user/repos?per_page=100").
        to_return(
          :status => 200,
          :body => fixture("repos"),
          :headers => { 'Content-Type' => 'application/json' }
        )
    end

    it "shows the securocat when github returns an oauth error" do
      get "/auth/github/callback?error=redirect_uri_mismatch"
      follow_redirect!
      expect(last_response.body).to match(%r{securocat\.png})
    end

    it "shows the index" do
      get "/"
      expect(last_response.status).to eql(200)
      expect(last_response.body).to match(/GitHub Uploader/)
      expected = /<li><a href="\/octocat\/Hello-World">Hello-World<\/a><\/li>/
      expect(last_response.body).to match(expected)
    end

    describe "trees" do
      before do
        stub_request(:get, "https://api.github.com/repos/octocat/Hello-World").
          to_return(
            :status => 200,
            :body => fixture("repo"),
            :headers => { 'Content-Type' => 'application/json' }
          )
      end

      it "shows a tree" do
        stub_request(:get, "https://api.github.com/repos/octocat/Hello-World/contents/").
          to_return(
            :status => 200,
            :body => fixture("repo-contents"),
            :headers => { 'Content-Type' => 'application/json' }
          )

        get "/octocat/Hello-World"
        expect(last_response.status).to eql(200)
        expect(last_response.body).to match(/GitHub Uploader/)
        expect(last_response.body).to match(/<li class="file">lib\/octokit.rb<\/li>/)
        expected = /<li class="directory"><a href="\/octocat\/Hello-World\/lib\/octokit">lib\/octokit<\/a><\/li>/
        expect(last_response.body).to match(expected)
      end

      it "shows a sub-tree" do
        stub_request(:get, "https://api.github.com/repos/octocat/Hello-World/contents/lib").
          to_return(
            :status => 200,
            :body => fixture("repo-sub-contents"),
            :headers => { 'Content-Type' => 'application/json' }
          )

        get "/octocat/Hello-World/lib"
        expect(last_response.status).to eql(200)
        expect(last_response.body).to match(/GitHub Uploader/)
        expect(last_response.body).to match(/<li class="file">\/octokit.rb<\/li>/)
      end

      it "allows the user to upload a file" do

      end
    end
  end
end
