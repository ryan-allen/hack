task :default => :spec

task :spec do
  puts `spec --color hack_spec.rb`
end