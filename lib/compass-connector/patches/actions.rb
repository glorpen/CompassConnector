module Compass
  module Actions

    # Write a file given the file contents as a string
    def write_file(file_name, contents, options = nil, binary = false)
      options[:force] = false
      options ||= self.options if self.respond_to?(:options)
      skip_write = options[:dry_run]
      contents = process_erb(contents, options[:erb]) if options[:erb]
      old_file = CompassConnector::Resolver.get_output_css(file_name)
      if old_file != nil
        existing_contents = old_file.read()
        if existing_contents == contents
          log_action :identical, basename(file_name), options
          skip_write = true
        else options[:force]
          log_action :overwrite, basename(file_name), options
        end
      else
        log_action :create, basename(file_name), options
      end
      if not skip_write
        CompassConnector::Resolver.put_output_css(file_name, contents)
      end
    end
    
  end
end
