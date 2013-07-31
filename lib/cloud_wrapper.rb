module CloudWrapper
  module Instance
    class Instance

      @@implementations = {}

#      def self.register(type, *clouds)
      def self.register(*clouds)
        CloudWrapper::Instance.register(clouds, self)
        puts("DEBUG: CloudWrapper::Instance.register class method is up with clouds -> #{clouds}")
      end

      private_class_method :register

      def initialize(cloud, api_version, options)
        @api_version = api_version
        @cloud = cloud.to_sym
        @log_dir = '/var/log/cloud_wrapper/'
        @knife_bin = '/opt/chef-server/embedded/bin/knife'
        puts("DEBUG: CloudWrapper::Instance.Initialize Class is up for #{cloud}")
      end

      def create(nickname, options = {})
        puts("DEBUG:not_implemented")
      end

    end # Class Instance End

    def self.register(this_cloud, implementation)
      case this_cloud
      when Array
        this_cloud.each { |cloud| register(cloud, implementation) }
        puts("  DEBUG: CloudWrapper::Instance.Register is up with implementation #{this_cloud.inspect} and #{implementation.inspect}")
        Instance.class_variable_get(:@@implementations)
        @@implementations = implementation
        puts("  DEBUG: CloudWrapper::Instance.Register is up with @@implementations #{@@implementations.inspect}")
      else
        puts("++DEBUG_in else: CloudWrapper::Instance.Register is up with implementation #{implementation.inspect}")
      end

    end

    def self.factory(this_cloud, api_version, options = {})
      require File.dirname(__FILE__) + "/cloud_wrapper/#{api_version}/wrapper_#{this_cloud}"
      #require File.dirname(__FILE__) + "/cloud_wrapper/#{api_version}/wrapper_openstack"

      raise 'Missing this_cloud' unless this_cloud
      Instance.class_variable_get(:@@implementations)
      puts("DEBUG: CloudWrapper::Instance.Factory @@implementations #{@@implementations} for cloud #{this_cloud}")
      implementation = @@implementations
      raise "Unsupported cloud #{this_cloud}}" unless implementation
     # options[:cloud] = this_cloud
      puts ("DEBUG: cloud #{this_cloud}")
      inst = implementation.new this_cloud, api_version, options
      puts("DEBUG: CloudWrapper::Instance.Factory is up with #{implementation.inspect} and  options = #{ options.inspect}")
      return inst
    end

  end
end

#require File.dirname(__FILE__) + '/cloud_wrapper/wrapper_openstack'
#\require File.dirname(__FILE__) + '/cloud_wrapper/wrapper'
#
#require File.dirname(__FILE__) + "/cloud_wrapper/v1/wrapper_openstack"
#require File.dirname(__FILE__) + "/cloud_wrapper/v1/wrapper_aws"