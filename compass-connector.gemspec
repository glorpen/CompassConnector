Gem::Specification.new do |s|
  s.name        = 'compass-connector'
  s.version     = '0.8.1'
  s.date        = '2013-05-18'
  s.summary     = "Compass integration with any framework"
  s.description = "Allows integration between Compass and any other framework with corresponding other-framework connector."
  s.authors     = ["Arkadiusz Dzięgiel"]
  s.email       = 'admin@glorpen.pl'
  s.files       = Dir['lib/**/*.rb']
  s.has_rdoc	= false
  s.license		= 'GPL-3'
  s.post_install_message = "To fully utilize this gem you should install connector app for your project"
  s.homepage    = 'http://bitbucket.org/glorpen/compassconnector'
  s.add_runtime_dependency 'compass'
  s.add_dependency('json', '>= 1.6.2')
end
