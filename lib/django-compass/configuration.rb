require "compass/configuration"

#Compass.configuration.output_style = "compressed"
#Compass.configuration.line_comments = false
#Compass.configuration.environment = "production"

module Compass
  module Configuration
    module Defaults
      
      def default_environment
        :production
      end

    end
  end
end
