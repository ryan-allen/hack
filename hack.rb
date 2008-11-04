%w(rubygems rack).each { |dep| require dep } 
require "#{File.dirname(__FILE__)}/3rd-party/eigenclass_instance_exec"

module Hack

  def self.run!(opts = {}, &app)
    Rack::Handler::Mongrel.run(App.new(&app), :Port => opts[:port])
  end

private

  class App

    def initialize(&app)
      @urls_in_order = {'GET' => [], 'POST' => []}
      @urls_to_proc  = {'GET' => {}, 'POST' => {}}
      instance_eval(&app)
    end

    def call(env)
      @urls_in_order[env['REQUEST_METHOD']].each do |url|
        if match = url.match(env['PATH_INFO'])
          return Cycle.new(match.captures, Rack::Request.new(env), env, &@urls_to_proc[env['REQUEST_METHOD']][url]).process!
        end
      end
      raise "can't find shit for #{env['PATH_INFO'].inspect}" # not sure how to test this with fork (yet)
    end

  private

    def get(url, &code)
      @urls_in_order['GET'] << /^#{url}$/
      @urls_to_proc['GET'][/^#{url}$/] = code
    end

    def post(url, &code)
      @urls_in_order['POST'] << /^#{url}$/
      @urls_to_proc['POST'][/^#{url}$/] = code
    end

    def uri(url, &code)
      @urls_in_order['GET'] << /^#{url}$/
      @urls_to_proc['GET'][/^#{url}$/] = code
      @urls_in_order['POST'] << /^#{url}$/
      @urls_to_proc['POST'][/^#{url}$/] = code
    end

  end

  class Cycle # as in, a request/response cycle

    attr_reader :env
    
    def initialize(captures, request, env, &code)
      @captures, @request, @env, @code = captures, request, env, code
    end

    def process!
      return_value = instance_exec(*@captures, &@code)
      if return_value.is_a?(Array)
        return_value
      elsif return_value.is_a?(String)
        [200, {}, return_value]
      elsif return_value.is_a?(Fixnum)
        [return_value, {}, '']
      else
        raise "unknown return value in process!: #{return_value.inspect}"
      end
    end

  private

    def redirect(location, status = :temporarily)
      [(status == :temporarily ? 302 : 301), {'Location' => location}, '']  
    end

    %w(GET POST).each do |request_method|
      
      define_method request_method.downcase do
        @request.send(request_method)
      end

      define_method request_method.downcase+"?" do
        env['REQUEST_METHOD'] == request_method
      end

    end

  end

end
