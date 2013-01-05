require "compass/sass_extensions/functions/image_size"

module Compass::SassExtensions::Functions::ImageSize
      def real_path(image_file)
        DjangoCompass.resolver("find_image", image_file)
      end
end
