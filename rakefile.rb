task :default => :spec

task :spec do
  puts `spec --color spec/hack_spec.rb`
end

task :markdown_to_html do
  require 'rubygems'
  require 'bluecloth'
  `rm README.html`
  open 'README.markdown', 'r' do |input|
    open "README.html", 'w+' do |output|
      output.write BlueCloth.new(input.read).to_html
    end
  end
end
