module CloudWrapper
  module Helper
    module Common

      def knife_run_output(logfile_name, mark = 'IP Address')
        logfile = "/var/log/cloud_wrapper/#{logfile_name}.log"
        if File.exists?(logfile)
          create_result = ''
=begin
          File.readlines(logfile).each do |line|
            puts line
            create_result.concat(line.chomp) if line.include?('IP Address')
            create_result.concat(line.chomp) if line.include?('Instance')
            if line.include?('FATAL' || 'Error')
              create_result.concat("See #{logfile} for details")
            end
          end
=end
          # Get immediate results for instance before chef run
          until create_result.include?(mark) do
            sleep 2
            create_result = ''
            File.readlines(logfile).each do |line|
              create_result << line.to_s
              create_result << '<br>'
            end
          end
        else
          create_result = "Unable to read #{logfile}."
        end
        return create_result.to_s
      end

=begin
      def option_checker(options)
        puts ("DEBUG OPT: #{caller[0][/`([^']*)'/, 1]}")

        # Common opts check
        raise 'Missing cloud' unless options[:cloud]
        raise 'Missing name/ID' unless options[:N]

        case caller[0][/`([^']*)'/, 1]
        when 'create'
          # create
          # N=chef-test-inst-4&f=9&I=c8dde561-a277-4cf2-85dd-802a82f47bde
          raise 'Missing flavor' unless options[:f]
          raise 'Missing Image name' unless options[:I]
        else
          puts 'Unknown action. Skipping options check'
        end
        # Insert options into command line query
        create_options = ''
        options.each_pair do |key, value|
          unless key == 'cloud'
            create_options << "-#{key} #{value} "
          end
        end

      end
=end

    end
  end
end


