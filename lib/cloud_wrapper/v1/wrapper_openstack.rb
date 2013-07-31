require File.dirname(__FILE__) + '/wrapper'

module CloudWrapper
  module Instance
    class WrapperOpenstack < WrapperBase
      register :openstack

      def initialize(cloud, nickname, options)
        super(cloud, nickname, options)
        puts("DEBUG: V1 CloudWrapper::Instance::WrapperOpenstack.initialize is up options #{options.inspect} and log dir #{@log_dir}")
        Dir.mkdir(@log_dir, 0666) unless Dir.exists?(@log_dir)
      end

      def create(nickname, opts)
        #Insering ome random numbers ro log file names
        # since there can be many instances with equal names
        # and we do not know instance ID yet
        knife_log_file_name = "openstack.#{rand(1000)}-#{rand(2000)}.#{nickname}.create"
        knife_log_file = "#{@log_dir}#{knife_log_file_name}.log"
        File.delete(knife_log_file) if File.exists?(knife_log_file)

        raise 'Missing Instance Name N= option' unless opts[:N]
        raise 'Missing flavor f= option' unless opts[:f]
        raise 'Missing Image name I= option' unless opts[:I]

        # Insert options into command line query
        create_options = ''
        opts.each_pair do |key, value|
          if key == 'cloud' or key == 'qr'
            puts "skipping #{key}"
          elsif key.size > 1
            create_options << "--#{key} #{value} "
          else
            create_options << "-#{key} #{value} "
          end
        end

        puts("DEBUG: V1 Will be   #.#{@knife_bin} openstack server create #{create_options}--no-host-key-verify > #{knife_log_file} \&")
        # Running instance create command into separate TTY
        begin
          # %x[#{@knife_bin} openstack server create #{create_options}--no-host-key-verify > #{knife_log_file} \&]
        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
        end

        return knife_log_file_name
      end

      def destroy(nickname, options)
        knife_log_file_name = "openstack.#{rand(1000)}-#{rand(2000)}.#{nickname}.destroy"
        knife_log_file = "#{@log_dir}#{knife_log_file_name}.log"
        File.delete(knife_log_file) if File.exists?(knife_log_file)
        puts("DEBUG: V1 Will be #/opt/chef-server/embedded/bin/knife openstack server delete #{nickname} -y > #{knife_log_file} \&")
        begin
        # %x[#{@knife_bin} openstack server delete #{nickname} -y > #{knife_log_file} \&]
        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
        end



        return knife_log_file_name
      end

      def list
        begin
          knife_out = %x[/opt/chef-server/embedded/bin/knife openstack server list]
        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
        end

        return knife_out
      end

    end
  end
end
