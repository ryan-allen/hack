require 'hack'

describe Hack do

  def start_app!(opts = {:port => 5555}, &app)
    @pid = fork do
      require 'hack'
      Hack.run!(opts, &app)
    end
    sleep 1# for some reason, it takes a tiny bit to start responding to curl?
  end
  
  def stop_app!
    `kill #{@pid}` if @pid
    @pid = nil
  end 
  
  before do  
    start_app! do
      get('/')      { 'I am HOMEPAGE!' }
      get('/about') { 'I am ABOUT!' }
    end
  end
  
  after do
    stop_app!
  end
  
  def get(uri)
    @body = `curl http://0.0.0.0:5555/ 2>/dev/null`.chomp
  end

  it 'can map GET: /' do
    get '/'
    @body.should == "I am HOMEPAGE!"
  end
  
  it 'can map GET: /about' do
    get '/about'
    @body.should == "I am ABOUT!"
  end

end
