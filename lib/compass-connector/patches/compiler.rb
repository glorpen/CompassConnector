require 'compass/compiler'

module Compass
  class Compiler
    
    attr_accessor(:django_sass)
    attr_accessor :sass_options
    
    def sass_files(options = {})
      exclude_partials = options.fetch(:exclude_partials, true)
      
      if self.options[:sass_files] != nil
        @sass_files = self.options[:sass_files]
      else
        @sass_files = []
        out = CompassConnector::Resolver.list_main_files
        out.to_enum.each do |item|
          @sass_files << item.to_s
        end
        
      end
      
      @sass_files
    end
    
    def stylesheet_name(sass_file)
      sass_file[0..-6].sub(/\.css$/,'')
    end
    
    # A sass engine for compiling a single file.
    def engine(sass_filename, css_filename)
      sass_filename = CompassConnector::Resolver.find_scss(sass_filename).to_s
      syntax = (sass_filename =~ /\.(s[ac]ss)$/) && $1.to_sym || :sass
      opts = sass_options.merge(:filename => sass_filename, :css_filename => css_filename, :syntax => syntax)
      Sass::Engine.new(open(sass_filename).read, opts)
    end
    
    def sass_options
      @sass_options[:load_paths] ||= []
      unless @sass_options[:load_paths].any? {|k| k.is_a?(::CompassConnector::Importer) }
         @sass_options[:load_paths] << ::CompassConnector::Importer.new()
      end
      @sass_options
    end
    
    def corresponding_css_file(sass_file)
      if sass_file.start_with? from
        sass_file = sass_file[from.length+1 .. -1]
      end
      
     "#{to}/#{stylesheet_name(sass_file)}.css"
    end
  end
end
