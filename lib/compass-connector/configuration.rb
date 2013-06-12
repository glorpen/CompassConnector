require "compass/configuration"

CompassConnector::Resolver.configuration().each do |key,value|
  if key == "plugins"
    value.each do |lib,version|
      gem lib, version
      require lib
    end
  else
    if value.is_a?String and value.start_with?(":")
      value[0]=''
      value = value.to_sym
    end
    Compass.configuration.send(key+"=", value)
  end
end

Compass.configuration.http_path = "/"
Compass.configuration.relative_assets = false
Compass.configuration.cache_path = Compass.configuration.project_path + "/.sass-cache"
