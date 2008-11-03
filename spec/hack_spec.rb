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
      get('/explicit-temporary-redirect') { redirect '/sweet', :temporarily }
      get('/explicit-permanent-redirect') { redirect '/err', :permanently }
      get('/four-oh-four') { 404 }
      get('/five-hungee') { 500 }
      get('/test-get') { "a was #{get['a']} and b was #{get['b']} and c was #{get['c']}" }
      # this catch all is here to test deterministic order of matching
      # if its' not deterministic it tends to catch a bunch of other
      # random ones, so we put catch all's last :)
      get('/(.*)') { |junk| 'i am the catch-all and i caught ' + junk }
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
    get '/default-redirect'
    @status.should == 302
    @headers['Location'].should == '/'
    @body.should == nil
  end

  it 'can redirect temporarily when specified' do
    get '/explicit-temporary-redirect'
    @status.should == 302
    @headers['Location'].should == '/sweet'
    @body.should == nil
  end

  it 'can redirect permanently when specified' do
    get '/explicit-permanent-redirect'
    @status.should == 301
    @headers['Location'].should == '/err'
    @body.should == nil
  end

  it 'can render blank statuses w/ ints, in this case 404' do
    get '/four-oh-four'
    @status.should == 404
    @body.should == nil
  end
  
  it 'can render a blank 500' do
    get '/five-hungee'
    @status.should == 500
    @body.should == nil
  end

  it 'can use that alternate "str", 404 for rendering w/ status too!'

  it 'can get out GET params' do
    get '/test-get?a=1&b=2&c=3'
    @status.should == 200
    @body.should == "a was 1 and b was 2 and c was 3"
  end

  it 'can get to the catch-all' do
    get '/hehe-some-random-url'
    @status.should == 200
    @body.should == 'i am the catch-all and i caught hehe-some-random-url'
  end

  it 'can get out POST params'
  it 'checks that redirect gets exactly either :permanently or :temporarily'
  it 'can serve files w/ the dirhandler'
  it 'can serve files w/ x-send-file'
  it 'can serve files w/ x-acell-redirect'
  it 'can serve via alias like: serve "images", :as => "i"'
  it 'has sessions & session data (steal rails cookie sessions)'
  it 'does that whole secret generation to .hack-secret'
  it 'has an access log'
  it 'has an error log'
  it 'supports post, put, delete'
  it 'has uri which does get/post/put/delete, and has get?/post? introspection methods, etc'
  it 'has filters, somehow, not sure how this will work'
  it 'hijacks include and includes it in whatever the app context is (Cycle)?'
  it 'can use that alternate Hack.app(...).run!(...) syntax from the README'
  it 'can be threaded or not threaded'
  it 'can specify what handler (thin/mongrel/fcgi) you want it to use'
  it 'has nice exception error pages (and a toggle for it on or off), steal merbs'
  it 'can mess with headers like content-type and etc'
  it 'can reload itself in a certain mode for code and fix (i.e. rails) style development'
  it 'has a set of rspec matchers or something so people can test hack apps very easily'
  it 'perhaps can work with rspec stories if i ever can be bothered looking into them (but this would be ace for integration style UATs or summat (and by that i mean, for people making hack apps)'

end
