require 'hack'

Hack.run! :port => 5555 do
  get '/' do
    "Ya mum's a web framework!\n"
  end
end
