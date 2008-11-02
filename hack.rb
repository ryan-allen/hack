%w(rubygems rack).each { |dep| require dep } 

module Hack
  def self.run!(opts = {}, &app)
    app = lambda { |env| [200, {}, 'Hello World!'] } 
    Rack::Handler::Mongrel.run(app, :Port => opts[:port])
  end
end
