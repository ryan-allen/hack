require 'hack'

describe Hack do

  def start_app!(&app)
    @pid = fork do
      require 'hack'
      Hack.run!(:port => 4000, &app)
    end
  end
  
  def stop_app!
    `kill #{@pid}` if @pid
    @pid = nil
  def 
  
  before do  
    start_app! do
      get('/') { 'Hello World!' }
    end
  end
  
  after do
    stop_app!
  end
  
  def body_should_include(uri, string)
    `curl http://0.0.0.0:4000#{uri}`.chomp.should =~ /#{string}/
  end

  it 'can map GET: /' do
    body_should_include '/', 'Hello World!'
  end
  
end