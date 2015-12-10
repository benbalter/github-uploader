require "spec_helper"

describe GitHubUploader::Helpers do
  class TestHelper
    include GitHubUploader::Helpers
    include Sinatra::Auth::Github::Test::Helper

    attr_accessor :session, :params

    def initialize(path=nil)
      @path = path
    end

    def request
      Rack::Request.new("PATH_INFO" => @path)
    end

    def github_user
      @user ||= make_user('login' => 'benbaltertest')
    end
  end

  before(:each) do
    @helper = TestHelper.new
    @helper.session = {}
    @helper.params = {}
  end

  it "knows the root directory" do
    root = File.expand_path "../lib", File.dirname(__FILE__)
    expect(@helper.root).to eql(root)
  end

  it "inits the client" do
    @helper.github_user[:token] = "ABCD"
    expect(@helper.client.class).to eql(Octokit::Client)
    expect(@helper.client.access_token).to eql("ABCD")
  end

  describe "with a repo" do
    before do
      @helper.params = {
        :user => "octocat",
        :repo => "Hello-World",
        :splat => ["/"]
      }
      @stub = stub_request(:get, "https://api.github.com/repos/octocat/Hello-World").
        to_return(
          :status => 200,
          :body => fixture("repo"),
          :headers => { 'Content-Type' => 'application/json' }
        )
    end

    it "pulls the repo" do
      expect(@helper.repo.name).to eql("Hello-World")
      expect(@stub).to have_been_requested
    end

    it "builds the nwo" do
      expect(@helper.nwo).to eql("octocat/Hello-World")
    end

    it "knows the path" do
      expect(@helper.path).to eql "/"
    end

    describe "with contents" do
      before do
        stub_request(:get, "https://api.github.com/repos/octocat/Hello-World/contents/").
          to_return(
            :status => 200,
            :body => fixture("repo-contents"),
            :headers => { 'Content-Type' => 'application/json' }
          )
        stub_request(:get, "https://api.github.com/repos/octocat/Hello-World/contents/lib").
          to_return(
            :status => 200,
            :body => fixture("repo-sub-contents"),
            :headers => { 'Content-Type' => 'application/json' }
          )
      end

      it "retrieve the tree" do
        expect(@helper.tree.first.name).to eql("octokit.rb")
      end

      it "checks if a file exists" do
        exists = @helper.file_exists? "/lib/octokit.rb"
        expect(exists).to eql(true)

        exists = @helper.file_exists? "/foo.rb"
        expect(exists).to eql(false)
      end

      it "uploads a file" do
        stub = stub_request(:put, "https://api.github.com/repos/octocat/Hello-World/contents/foo.txt").
          with(:body => "{\"content\":\"YmFyCg==\",\"message\":\"Upload foo.txt\"}").
          to_return(:status => 200)

        @helper.upload "/foo.txt", "Upload foo.txt", fixture_path("foo.txt")
        expect(stub).to have_been_requested
      end

      it "uploads a duplicate file" do
        stub = stub_request(:put, "https://api.github.com/repos/octocat/Hello-World/contents/lib/octokit.rb").
         with(:body => "{\"sha\":\"3d21ec53a331a6f037a91c368710b99387d012c1\",\"content\":\"YmFyCg==\",\"message\":\"Upload octokit.rb\"}").
           to_return(:status => 200)

        stub_request(:get, "https://api.github.com/repos/octocat/Hello-World/contents/lib/octokit.rb").
          to_return(
            :status => 200,
            :body => fixture("file"),
            :headers => { 'Content-Type' => 'application/json' }
          )

        @helper.upload "/lib/octokit.rb", "Upload octokit.rb", fixture_path("foo.txt")
        expect(stub).to have_been_requested
      end

      it "processes an upload" do
        stub = stub_request(:put, "https://api.github.com/repos/octocat/Hello-World/contents/foo.txt").
          with(:body => "{\"content\":\"YmFyCg==\",\"message\":\"Upload foo.txt\"}").
          to_return(:status => 200)

        @helper.params['filename'] = "foo.txt"
        @helper.params['path']     = fixture_path("foo.txt")

        @helper.process_upload
        expect(stub).to have_been_requested
      end
    end
  end
end
