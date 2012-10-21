require 'compass/sass_extensions/functions/urls'

module Compass::SassExtensions::Functions::Urls
  module ImageUrl
    def image_url(path, only_path = Sass::Script::Bool.new(false), cache_buster = Sass::Script::Bool.new(true))
      path = path.value
      p path, only_path
      DjangoCompass.find_asset(path)
      clean_url(path)
    end
  end
end