#
# The Hack API, by Ryan Allen
#

# Basic GET using #uri:

Hack.app do
  uri (or map or get? maybe get...) '/' do
    'Hello World'
  end
end

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

Hack.run!(:port => 4000) { url('/') { 'Hello World!' } }

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

# Including custom modules for the 'actions' to use:

module OurTemplateEngine
  def render_template(template)
    "You rendered #{template}!"
  end
end

Hack.app do
  include OurTemplateEngine  
  uri '/' do
    render_template 'home' # returns "You rendered home!"
  end
end

# Using regex capture groups in uri definitions, as paramaters, this rules:

Hack.app do
  uri '/user/(\w+)', :as => :users_hompeage do |username|
    "Welcome to #{username}'s page."
  end
  uri '/user/(\w+)/edit' do |username|
    "Trying to edit #{username}'s profile, eh?"
  end
end

#
# These TODOs are listed by priority:
#

# TODO: Working with sessions. They'll be cookie based, stolen form Rails :)
#  - auto-generates a secret to ./.hack-secret, uses that, rather than having
#    to specify your own.
# TODO: accessing request/response/session/params, via an OpenStruct
# TODO: Nice exception handling
# TODO: access.log, error.log
# TODO: Filters, somehow...
# TODO: Nesting uri's, is this even a good idea?
