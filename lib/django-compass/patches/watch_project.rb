require "compass/commands/watch_project"

module Compass
  module Commands
    class WatchProject
      
      attr_accessor :last_sass_files
      
      def perform
        Signal.trap("INT") do
          puts ""
          exit 0
        end
      
        check_for_sass_files!(new_compiler_instance)
        recompile
      
        require 'fssm'
      
        if options[:poll]
          require "fssm/backends/polling"
          # have to silence the ruby warning about chaning a constant.
          stderr, $stderr = $stderr, StringIO.new
          FSSM::Backends.const_set("Default", FSSM::Backends::Polling)
          $stderr = stderr
        end
      
        action = FSSM::Backends::Default.to_s == "FSSM::Backends::Polling" ? "polling" : "watching"
      
        puts ">>> Compass is #{action} for changes. Press Ctrl-C to Stop."
        $stdout.flush
      
        begin
        FSSM.monitor do |monitor|
          paths = Compass.configuration.sass_load_paths
          DjangoCompass.resolver("list_scss_dirs").to_enum.each do |item|
            paths << item.to_s
          end
          
          paths.each do |load_path|
            load_path = load_path.root if load_path.respond_to?(:root)
            
            next unless load_path.is_a? String
            next unless File.directory? load_path
            
            monitor.path load_path do |path|
              path.glob '**/*.s[ac]ss'
      
              path.update &method(:recompile)
              path.delete {|base, relative| remove_obsolete_css(base,relative); recompile(base, relative)}
              path.create &method(:recompile)
            end
          end
          Compass.configuration.watches.each do |glob, callback|
            monitor.path Compass.configuration.project_path do |path|
              path.glob glob
              path.update do |base, relative|
                puts ">>> Change detected to: #{relative}"
                $stdout.flush
                callback.call(base, relative)
              end
              path.create do |base, relative|
                puts ">>> New file detected: #{relative}"
                $stdout.flush
                callback.call(base, relative)
              end
              path.delete do |base, relative|
                puts ">>> File Removed: #{relative}"
                $stdout.flush
                callback.call(base, relative)
              end
            end
          end
      
        end
      rescue FSSM::CallbackError => e
        # FSSM catches exit? WTF.
        if e.message =~ /exit/
          exit
        end
      end
      end
      def remove_obsolete_css(base = nil, relative = nil)
        compiler = new_compiler_instance(:quiet => true)
        css_file = compiler.corresponding_css_file(relative)
        remove(css_file) if File.exists?(css_file)
      end
    end
  end
end
