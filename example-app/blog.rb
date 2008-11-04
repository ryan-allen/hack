# run from the library path (i.e. hack) with 'ruby example-app/blog.rb'

%w(hack yaml).each { |lib| require lib }

DATA_PATH = "#{File.dirname(__FILE__)}/data.yml"

Hack.run! :port => 5555 do

  # next feature we'll add is include-jacking, you'll be able
  # to include a module that'll make methods available inside
  # all those code blocks below, so we could DRY up all this
  # common arse-ness-ness and also include text helpers from
  # other frameworks so we don't have to make our own :)

  get '/' do
    @posts = YAML.load_file(DATA_PATH) if File.exist?(DATA_PATH)
    @html  = '<html><head><title>Hack Blog</title></head><body><h1>Hack Blog</h1><h2>Posts</h2>'
    if @posts
      @html << "<ul>"
      @posts.each do |post|
        @html << "<li><h3><a href=\"#{post[:permalink]}\">#{post[:title]}</a> (#{post[:posted]})</a></h3></li>"
      end
      @html << "</ul>"
    else
      @html << "<p>There are no posts :(</p>"
    end
    @html << "<p><a href=\"create\">Create a Post</a></p>"
    @html << '</body></html>'
  end

  get '/create' do
    @html = <<-html
      <html><head><title>Create Post</title></head><body><h1>Create Post</h1>
      <form method="POST">
        <p>Title <input type="text" name="title" /></p>
        <p>Content <textarea name="content"></textarea></p>
        <p>Password <input type="text" name="password" /></p>
        <p><input type="submit" name="Create Post" /> or <a href="/">Cancel</a></p>
      </form>
      </body></html>
    html
  end

  post '/create' do
    if post['password'] == 'password'
      @posts = File.exist?(DATA_PATH) ? YAML.load_file(DATA_PATH) : []
      @posts << {:title => post['title'],
                 :permalink => post['title'].downcase.gsub(/[^\w\d]+/, '-'),
                 :content => post['content'],
                 :posted => Time.now}
      open(DATA_PATH, 'w') { |f| f.write @posts.to_yaml }
      redirect '/' + @posts.last[:permalink]
    else
      redirect '/bad-password'
    end
  end

  get '/bad-password' do
    @html = <<-html
      <html><head><title>Bad Password</title></head><body><h1>Bad Password</h1>
      <p>You entered the wrong password, which means it's a bad one.</p>
      <p><small>P.S. The password is password.</small></p>
      </body></html>
    html
  end

  # right, so url parsing has to be done in a deterministic order
  get '/(.*)' do |permalink|
    if File.exist?(DATA_PATH)
      @posts = YAML.load_file(DATA_PATH)
      @post = @posts.find { |post| post[:permalink] == permalink }
      if @post
        @html = <<-html
          <html><head><title>#{@post[:title]}</title></head><body><h1>#{@post[:title]}</h1>
          <p>Posted #{@post[:posted]}</p>
          <p>#{@post[:content]}</p>
          <p><a href="/">Back</a>
          </body></html>
        html
      else
        404
      end
    else
      404
    end
  end
  
end
