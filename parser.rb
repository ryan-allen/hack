out = <<-server
HTTP/1.1 200 OK
Connection: close
Date: Sun, 02 Nov 2008 08:30:52 GMT
Content-Length: 26

Ya mum's a web framework!
server

lines = out.split("\n")
status = lines.shift
boundary = lines.index('')
headers, body = lines[0...boundary], lines[boundary+1..lines.length]
puts headers.inspect
puts body.inspect
