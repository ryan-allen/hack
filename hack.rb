%w(rubygems rack).each { |dep| require dep } 

module Hack

  def self.run!(opts = {}, &app)
    Rack::Handler::Mongrel.run(App.new(&app), :Port => opts[:port])
  end

private

  class App

    def initialize(&app)
      @urls = {} 
      instance_eval(&app)
    end

    def call(env)
      # return [200, {}, env.inspect] # good for env debugging :)
      @urls.each do |pattern, code|
        if env['PATH_INFO'] =~ pattern 
          return [200, {}, code.call]
        end
      end
      raise "can't find shit for #{env['PATH_INFO'].inspect}" # not sure how to test this with fork
    end

  private

    def get(url, &code)
      @urls[/^#{url}$/] = code
    end

  end

end
