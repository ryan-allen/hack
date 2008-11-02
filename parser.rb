out = <<-server
HTTP/1.1 200 OK
Connection: close
Date: Sun, 02 Nov 2008 08:30:52 GMT
Content-Length: 26

Ya mum's a web framework!
server

lines = out.split("\n")
raw_status = lines.shift
match = raw_status.match(/HTTP\/\d\.\d (\d+)/)
status = match.captures[0].to_i
puts status
boundary = lines.index('')
headers, body = lines[0...boundary], lines[boundary+1..lines.length]
puts headers.inspect
puts body.inspect
processed_headers = {}
headers.each do |raw_header|
  processed_headers[raw_header[0...raw_header.index(':')]] = raw_header[raw_header.index(':')+1..raw_header.length]
end
puts processed_headers.inspect
