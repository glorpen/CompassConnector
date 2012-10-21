require "compass/sass_extensions/sprites/sprite_map"

module Compass
  module SassExtensions
    module Sprites
      class SpriteMap < Sass::Script::Literal
        def self.relative_name(sprite)
          return sprite
        end
      end
    end
  end
end
