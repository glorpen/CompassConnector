require 'compass/compiler'
module Compass
  class Compiler
    attr_accessor :sass_options
    #STYLESHEET = /stylesheet/
    def sass_options
      if TRUE
        #puts @sass_options
        @sass_options[:custom] ||= {}
        #@sass_options[:custom] = {:resolver => ::DjangoCompass::Resolver.new(CompassRails.context)}
        @sass_options[:load_paths] ||= []
        unless @sass_options[:load_paths].any? {|k| k.is_a?(::DjangoCompass::Importer) }
          #::Rails.application.assets.paths.each do |path|
            #next unless path.to_s =~ STYLESHEET
            #Dir["#{path}/**/*"].each do |pathname|
            #  puts pathname
              # args are: sprockets environment, the logical_path ex. 'stylesheets', and the full path name for the render
              #context = ::CompassRails.context.new(::Rails.application.assets, File.basename(path), Pathname.new(pathname))
             @sass_options[:load_paths] << ::DjangoCompass::Importer.new()
            #end
          #end
        end
      end
      @sass_options
    end

  end
end
