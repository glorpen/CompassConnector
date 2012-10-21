require "compass/sprite_importer"

module Compass
  class SpriteImporter < Sass::Importers::Base
    # Returns the Glob of image files for the uri
    def self.files(uri)
      
      files = []
      DjangoCompass.resolver.find_sprites_matching(uri).to_enum.each do |item|
        files << item.to_s
      end
      
      if not files.empty?
        return files
      end
      
      raise Compass::SpriteException, %Q{No files were found in the load path matching "#{uri}".}
    end
    
    # The on-disk location of this sprite
    def self.path(uri)
      path, _ = path_and_name(uri)
      p path
      path
    end
    
  end
end
