require 'hack'

describe Hack do

  def start_app!(opts = {:port => 5555}, &app)
    @pid = fork do
      require 'hack'
      Hack.run!(opts, &app)
    end
    sleep 0.5 # for some reason, it takes a tiny bit to start responding to curl?
  end
  
  def stop_app!
    `kill #{@pid}` if @pid
    @pid = nil
  end 
  
  before do  
    start_app! do
      get('/') { 'Hello World!' }
    end
  end
  
  after do
    stop_app!
  end
  
  def get(uri)
    @body = `curl http://0.0.0.0:4000/ 2>/dev/null`
  end

  it 'can map GET: /' do
    get '/'
    @body.should =~ /Hello World!/
  end
  
end
