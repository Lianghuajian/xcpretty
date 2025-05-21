module XCPretty
  class JSONCompilationDatabase < Reporter

    FILEPATH = 'build/reports/compilation_db.json'

    def load_dependencies
      unless @@loaded ||= false
        require 'fileutils'
        require 'pathname'
        require 'json'
        @@loaded = true
      end
    end

    def initialize(options)
      super(options)
      @compilation_units = []
      @pch_path = nil
      @current_file = nil
      @current_path = nil
    end

    def format_process_pch_command(file_path)
      @pch_path = file_path
    end

    def format_compile(file_name, file_path)
      @current_file = file_name
      @current_path = file_path
    end

    def format_compile_command(compiler_command, file_path)
      # Handle the case where @current_path is nil
      if @current_path.nil?
        directory = file_path.gsub(/\/$/, '') # Remove trailing slash if present
        directory = '/' if directory.empty?
        file = directory
      else
        directory = file_path.gsub("#{@current_path}", '').gsub(/\/$/, '')
        directory = '/' if directory.empty?
        file = @current_path
      end
    
      # If directory is empty, set it to "/"
      directory = '/' if directory.empty?
    
      # If directory ends with a file extension, truncate to the previous "/"
      if directory.match?(/\.(?:m|mm|c|cc|cpp|cxx|swift)$/)
        directory = directory.sub(/\/[^\/]+$/, '')
        directory = '/' if directory.empty?
      end
    
      # Replace the .pch path if @pch_path is provided
      cmd = compiler_command
      cmd = cmd.gsub(/(\-include)\s.*\.pch/, "\\1 #{@pch_path}") if @pch_path
    
      # Add the compilation unit to the list
      @compilation_units << { command: cmd, file: file, directory: directory }
    end

    def write_report
      File.open(@filepath, 'w') do |f|
        f.write(@compilation_units.to_json)
      end
    end
  end
end

