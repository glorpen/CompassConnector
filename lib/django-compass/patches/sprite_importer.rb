require "compass/sprite_importer"

module Compass
  class SpriteImporter
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
    
  end
end
