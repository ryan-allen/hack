require '../hack'

module Blog
  # probably going to need to be able to use mutexes here for reading and writing... 
end

Hack.run! :port => 5555 do

  get '/' do
    'homepage (showing posts)'
  end

  # this needs to be POST
  get '/create' do
    'creating a post with ' + get.inspect
  end

  # right, so url parsing has to be done in a deterministic order
  get '/(.*)' do |permalink|
    'viewing post ' + permalink
  end
  
end
