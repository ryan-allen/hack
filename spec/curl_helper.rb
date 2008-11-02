module CurlHelper
  
  def curl(uri)
    parse `curl http://0.0.0.0:5555#{uri} 2>/dev/null`.chomp
  end

private

  def parse(output)
    lines = output.split("\n")
    raw_status = lines.shift
    match = raw_status.match(/HTTP\/\d\.\d (\d+)/)
    status = match.captures[0].to_i
    boundary = lines.index('')
    raw_headers, body = lines[0...boundary], lines[boundary+1..lines.length].join("\n")
    headers = {}
    raw_headers.each do |raw_header|
      headers[raw_header[0...raw_header.index(':')]] = raw_header[raw_header.index(':')+2..raw_header.length]
    end
    [status, headers, body]
  end

end

if __FILE__ == $0

  require 'test/unit'

  class CurlHelperTest < Test::Unit::TestCase

    include CurlHelper

    def setup 
      @output = <<-server_output
HTTP/1.1 200 OK
Connection: close
Date: Sun, 02 Nov 2008 08:30:52 GMT
Content-Length: 26

Ya mum's a web framework!
      server_output
      @status, @headers, @body = parse(@output)
    end

    def test_status
      assert_equal 200, @status
    end

    def test_headers
      assert_equal 'close', @headers['Connection']
      assert_equal 'Sun, 02 Nov 2008 08:30:52 GMT', @headers['Date']
      assert_equal '26', @headers['Content-Length']
    end

    def test_body
      assert_equal "Ya mum's a web framework!", @body
    end

  end
  
end
