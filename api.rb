# Basic GET using #uri:

Hack.app do
  uri '/' do
    'Hello World'
  end
end.run! :port => 4000

# GET/POST/PUT/DELETE:

Hack.app do
  get('/') { 'You got me' }
  post('/') { 'You posted me' }
  put('/') { 'You put me' }
  delete('/') { 'You deleted me' }
end

# (Possible) alternative syntax:

Hack.app do
  uri '/' do
    get { 'You got me' }
    post { 'You posetd me' }
    put { 'You put me' }
    delete { 'You deleted me' }
  end
end

# Running an app on port 4000:

@app = Hack.app { url('/') { 'Hello World!' } }
@app.run! :port => 4000

# Alternative syntax:

Hack.app(:port => 4000) { url('/') { 'Hello World!' } }

# Serving a path (+ performance awesome for Apache/Lighttpd/Nginx):

Hack.app do
  serve 'images' # mounts images using Rack::DirHandler
  serve 'music', :via => :x_send_file # uses x-sendfile (Apache/Lighttpd)
  serve 'video', :via => :x_acell_redirect # uses x-acell-redirect (Nginx)
end

# Redirecting requests (w/ permanent + temporary options):

Hack.app do
  uri('/') { 'Welcome home.' }
  url('/go-home-for-a-bit') { redirect '/', :temporarily }
  uri('/go-home-forever') { redirect '/', :permanently }
end

# 404, 500, + custom status rendering:

Hack.app do
  uri('/404') { 404 }
  uri('/500') { 500 }
  uri('/custom-404') { 'Page not found.', 404 }
  uri('/custom-500') { 'Error, damnit!', 404 }
end

# Turning off threading:

Hack.app :threaded => false do
  uri '/' do
    sleep 10 # will block other requests for 10 seconds
  end
end

# Sessions... this is important, but dunno yet.
# Including custom modules to the request/response servlet cycle...
# Nesting uri's