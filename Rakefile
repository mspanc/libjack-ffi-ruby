require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "jack-ffi"
    gemspec.summary = "JACK bindings via FFI"
    gemspec.description = "Jack Audio Connection Kit Bindings via FFI interface"
    gemspec.email = "marcin@saepia.net"
    gemspec.homepage = "http://jack-ffi.saepia.net"
    gemspec.authors = ["Marcin Lewandowski"]
    
    gemspec.files = FileList['lib/**/*.rb', 'GPL3-LICENSE', 'Rakefile', 'VERSION']
    gemspec.add_dependency "ffi"    

    Jeweler::GemcutterTasks.new
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end


