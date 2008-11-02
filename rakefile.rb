task :default => :spec

task :spec do
  puts `spec --color spec/hack_spec.rb`
end
