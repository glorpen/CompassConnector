require 'compass/sass_extensions/functions/urls'

module Compass::SassExtensions::Functions::Urls
  module ImageUrl
    def image_url(path, only_path = Sass::Script::Bool.new(false), cache_buster = Sass::Script::Bool.new(true))
      path = path.value
      path = DjangoCompass.resolver.image_url(path).to_s
      
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
      
      path = DjangoCompass.resolver.font_url(path).to_s

      if only_path.to_bool
        Sass::Script::String.new(clean_path(path))
      else
        clean_url(path)
      end
    end
  end
end