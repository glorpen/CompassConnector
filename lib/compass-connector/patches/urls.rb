require 'compass/sass_extensions/functions/urls'

module Compass::SassExtensions::Functions::Urls
  module ImageUrl
    def image_url(path, only_path = Sass::Script::Bool.new(false), cache_buster = Sass::Script::Bool.new(true))
      path = path.value
      
      real_path = CompassConnector::Resolver.find_image(path)
      path = CompassConnector::Resolver.image_url(path)
      
      # Compute and append the cache buster if there is one.
      if cache_buster.to_bool
        if cache_buster.is_a?(Sass::Script::String)
          path += "?#{cache_buster.value}"
        else
          path = cache_busted_path(path, real_path)
        end
      end
      
      if only_path.to_bool
        Sass::Script::String.new(clean_path(path))
      else
        clean_url(path)
      end
    end
  end
  module FontUrl
    def font_url(path, only_path = Sass::Script::Bool.new(false))
      path = path.value # get to the string value of the literal.
      
      path = CompassConnector::Resolver.font_url(path)

      if only_path.to_bool
        Sass::Script::String.new(clean_path(path))
      else
        clean_url(path)
      end
    end
  end
  module StylesheetUrl
    def stylesheet_url(path, only_path = Sass::Script::Bool.new(false))
      path = path.value # get to the string value of the literal.
      
      path = CompassConnector::Resolver.stylesheet_url(path)

      if only_path.to_bool
        Sass::Script::String.new(clean_path(path))
      else
        clean_url(path)
      end
    end
  end
  module GeneratedImageUrl
    def generated_image_url(path, cache_buster = Sass::Script::Bool.new(false))
      path = path.value # get to the string value of the literal.
      
      real_path = CompassConnector::Resolver.find_generated_image(path)
      path = CompassConnector::Resolver.generated_image_url(path)
      
      # Compute and append the cache buster if there is one.
      if cache_buster.to_bool
        if cache_buster.is_a?(Sass::Script::String)
          path += "?#{cache_buster.value}"
        else
          path = cache_busted_path(path, real_path)
        end
      end

      clean_url(path)
    end
  end
end