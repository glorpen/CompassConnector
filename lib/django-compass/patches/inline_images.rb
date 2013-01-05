require "compass/sass_extensions/functions/inline_image"

module Compass::SassExtensions::Functions::InlineImage

  def inline_image(path, mime_type = nil)
    path = path.value
    real_path = DjangoCompass.resolver("find_image", path)
    inline_image_string(data(real_path), compute_mime_type(path, mime_type))
  end

  def inline_font_files(*args)
    raise Sass::SyntaxError, "An even number of arguments must be passed to font_files()" unless args.size % 2 == 0
    files = []
    while args.size > 0
      path = args.shift.value
      real_path = DjangoCompass.resolver("find_font", path)
      url = inline_image_string(data(real_path), compute_mime_type(path))
      files << "#{url} format('#{args.shift}')"
    end
    Sass::Script::String.new(files.join(", "))
  end
end
