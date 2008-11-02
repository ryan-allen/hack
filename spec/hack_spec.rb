require 'hack'
require 'spec/curl_helper'

describe Hack do

  include CurlHelper

  def start_app!(opts = {:port => 5555}, &app)
    @pid = fork do
      require 'hack'
      Hack.run!(opts, &app)
    end
  end
  
  def stop_app!
    `kill #{@pid}` if @pid
    @pid = nil
  end 
  
  before do  
    start_app! do
      get('/') { 'I am HOMEPAGE!' }
      get('/about') { 'I am ABOUT!' }
      get('/show/(\d+)') { |id| "Looking at #{id}" }
      get('/show/(\d+)/edit') { |id| "You are editing #{id}" }
      get('/default-redirect') { redirect '/' }
    end
  end
  
  after do
    stop_app!
  end
  
  def get(uri)
    sleep 1 # for some reason, it takes a tiny bit to start listening on 5555? 
    @status, @headers, @body = curl("http://localhost:5555#{uri}")
  end

  it 'can map GET: /' do
    get '/'
    @body.should == 'I am HOMEPAGE!'
  end
  
  it 'can map GET: /about' do
    get '/about'
    @body.should == 'I am ABOUT!'
  end

  it 'can capture a single param from a url' do
    get '/show/42'
    @body.should == 'Looking at 42'
  end

  it 'matches similar (extended?) paths correctly' do
    get '/show/42/edit'
    @body.should == "You are editing 42"
  end

  it 'raises exception when we try to get a path that it cannot match'

  it 'redirects temporarily by deafult' do
    #get '/a-default-redirect'
    #@status.should == 301
    #@headers['Location'].should == '/'
  end

  it 'can redirect temporarily when specified'
  it 'can redirect permanently when specified'
  it 'can render blank statuses w/ ints, in this case 404'
  it 'can render a blank 500'
  it 'can get out GET params'
  it 'can get out POST params'
  it 'can serve w/ a dirhandler'
  it 'can serve files w/ x-send-file'
  it 'can serve files w/ x-acell-redirect'

end
