Gem::Specification.new do |s|
  s.name        = 'django-compass'
  s.version     = '0.0.2'
  s.date        = '2012-10-22'
  s.summary     = "Compass integration with Django"
  s.description = "Allows integration between Django and Compass"
  s.authors     = ["Arkadiusz Dzięgiel"]
  s.email       = 'admin@glorpen.pl'
  s.files       = Dir['lib/**/*.rb']
  s.license	= 'GPL-3'
  s.post_install_message = "To use this gem you should install django-compass app in your Django project"
  s.homepage    = 'http://bitbucket.org/glorpen/django-compass-ruby'
  s.add_runtime_dependency 'compass'
end
