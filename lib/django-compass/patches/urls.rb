require 'compass/sass_extensions/functions/urls'

module Compass::SassExtensions::Functions::Urls
  module ImageUrl
    def image_url(path, only_path = Sass::Script::Bool.new(false), cache_buster = Sass::Script::Bool.new(true))
      path = path.value
      path = DjangoCompass.resolver.image_url(path).to_s
      clean_url(path)
    end
  end
end