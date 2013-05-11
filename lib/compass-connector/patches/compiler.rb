require 'compass/compiler'

module Compass
  class Compiler
    
    attr_accessor(:django_sass)
    attr_accessor :sass_options
    
    def sass_files(options = {})
      exclude_partials = options.fetch(:exclude_partials, true)
      
      if self.options[:sass_files] != nil
        @sass_files = []
        self.options[:sass_files].each { |f|
          @sass_files << shorten_path(f)
        }
      else
        raise "Cannot compile project, only single files is supported"
      end
      
      @sass_files
    end
    
    def stylesheet_name(sass_file)
      sass_file[0..-6].sub(/\.css$/,'')
    end
    
    def shorten_path(path)
      if path.start_with?(Dir.pwd)
        path[Dir.pwd.length+1..-1]
      else
        path
      end
    end
    
    # A sass engine for compiling a single file.
    def engine(sass_filename, css_filename)
      sass_filename = shorten_path(sass_filename)
      css_filename = corresponding_css_file(sass_filename)
      
      sass_file = CompassConnector::Resolver.find_import(sass_filename)
      if not sass_file
        raise "File '#{sass_filename}' was not found"
      end
      syntax = (sass_filename =~ /\.(s[ac]ss)$/) && $1.to_sym || :sass
      opts = sass_options.merge(:filename => sass_filename, :css_filename => css_filename, :syntax => syntax)
      Sass::Engine.new(sass_file.read, opts)
    end
    
    def sass_options
      @sass_options[:load_paths] ||= []
      unless @sass_options[:load_paths].any? {|k| k.is_a?(::CompassConnector::Importer) }
         @sass_options[:load_paths] << ::CompassConnector::Importer.new()
      end
      @sass_options
    end
    
    def corresponding_css_file(sass_file)
     "#{stylesheet_name(sass_file)}.css"
    end
  end
end
