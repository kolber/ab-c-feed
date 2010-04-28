__DIR__ = File.dirname(__FILE__)

require 'lib/core_ext/enumerable'
require 'ftools'

require '.bundle/environment'
Bundler.require

%w(helpers article haml-filter).each{|r| require "#{__DIR__}/lib/#{r}" }
Article.path = "#{__DIR__}/articles"

module Feed
  class Application < Sinatra::Base
    set :logging, true
    set :public, File.join(File.dirname(__FILE__), 'public')
    set :haml, {:format => :html5, :attr_wrapper => '"'}
    enable :static
    
    configure :production do
      ENV['APP_ROOT'] ||= File.dirname(__FILE__)
      $:.unshift "#{ENV['APP_ROOT']}/vendor/plugins/newrelic_rpm/lib"
      require 'newrelic_rpm'
    end
    
    helpers do
      include Helpers
    end
      
    get '/' do
      @articles = Article.all.sort
      haml :index, {:layout => :layout}
    end
    
    get '/articles' do
      @articles = Article.all.sort
      haml :index, {:layout => :layout}
    end
    
    get '/articles/:id' do
      @article = Article[params[:id]] || raise(Sinatra::NotFound)
      haml :article, {:layout => :inner_layout}
    end

    get '/articles.atom' do
      @articles = Article.all.sort
      content_type 'application/atom+xml'
      haml :feed, {:format => :xhtml, :layout => false}
    end
    
    get '/css/*' do
      begin
        content_type 'text/css'
        response["Expires"] = (Time.now + 60*60*24*356*3).httpdate # Cache for 3 years
        Tilt.new("#{File.dirname(__FILE__)}/public/css/#{File.basename(params[:splat].join, ".*")}.less").render
      rescue Errno::ENOENT
        content_type 'text/html'
        not_found
      end
    end

    not_found do
      haml :not_found
    end
    
    error(500..599) do
      haml :application_errors
    end
  end
end 
