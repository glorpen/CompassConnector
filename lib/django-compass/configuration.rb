require "compass/configuration"

CompassConnector::Resolver.configuration().each do |key,value|
  if value.is_a?String and value.start_with?(":")
    value[0]=''
    value = value.to_sym
  end
  Compass.configuration.send(key+"=", value)
end
