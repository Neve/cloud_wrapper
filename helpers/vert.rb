require 'pp'
require "fog"

module AWS
  class Worker
    attr_accessor :ec2
    def initialize(key, secret, endpoint)
      # REGION?
      @ec2 = Fog::Compute.new(:provider => 'aws', :aws_access_key_id => key, :aws_secret_access_key => secret, :endpoint => endpoint)
    end

    def DescribeInstances
      @ec2.servers
    end

    def DescribeInstance(instance_id)
      @ec2.servers.get(instance_id)
    end

    def RunInstance(params={})
      server = @ec2.servers.new
      server.image_id = params[:image_id] || 'ami-006d4c45'
      #server.client_token = RightScale::CloudApi::Utils::generate_token
      server.availability_zone = params[:region] || @ec2.region || "us-west-1a"
      server.flavor_id = params[:instance_type] || 't1.micro'
      server.save
    end

    def StopInstance(instance_id)
      @ec2.servers.get(instance_id).stop
    end

    def StartInstance(instance_id)
      @ec2.servers.get(instance_id).start
    end

    def wait_until(instance_id, st = 'running')
      pp "Instance id: #{instance_id}"
      puts "Waiting for #{st} state..."
      timeout = 60
      try_until = Time.now + timeout
      loop do
        server = @ec2.servers.get(instance_id)
        status = server.state
        puts "Status: #{status}"
        break if status && status == st
        if timeout?(try_until)
          raise "Failed to discover Instance with id: #{instance_id} within #{timeout} seconds."
        else
          sleep 5
        end
      end
    end

    def ModifyInstanceAttribute(instance_id, new_instance_type)
      @ec2.modify_instance_attribute(instance_id, {'InstanceType.Value' => new_instance_type || 'm1.small'})
    end

    def scale_up(instance)
      instance_id = instance.id
      StopInstance(instance_id)
      wait_until(instance_id, "stopped")
      ModifyInstanceAttribute(instance_id)
      StartInstance(instance_id)
      w.wait_until(instance_id)
      DescribeInstance(instance_id)
    end

    def TerminateInstance(instance_id)
      puts "Terminating"
      pp @ec2.servers.get(instance_id).destroy
    end

    def timeout?(try_until)
      Time.now > try_until
    end
  end
end

#================RAX and OS===========
require 'pp'
require "fog"
require "extensions/fog"

module RaxNG
  class Worker
    attr_accessor :rax
    def initialize(username, auth_key, tenant_id, region, endpoint)
      @rax = Fog::Compute.new(:provider => 'Rackspace',
                              :version => 'v2',
                              :rackspace_api_key => auth_key,
                              :rackspace_username => username,
                              :rackspace_endpoint => "https://#{region}.servers.api.rackspacecloud.com/v2",
                              :rackspace_auth_url => "https://identity.api.rackspacecloud.com/v2.0/tokens",
                              :rackspace_tenant_id => tenant_id)
    end

    def DescribeInstances
      @rax.servers
    end

    def DescribeInstance(instance_id)
      @rax.servers.get(instance_id)
    end

    def RunInstance(params={})
      server = @rax.servers.new
      server.image_id = params[:image_id] || "03318d19-b6e6-4092-9b5c-4758ee0ada60"
      server.flavor_id = params[:instance_type] || '2'
      server.name = params[:name] || 'khrvi_test_delete_me',
      server.save
    end

    def wait_until(instance_id, st = 'ACTIVE')
      pp "Instance id: #{instance_id}"
      puts "Waiting for #{st} state..."
      timeout = 360
      try_until = Time.now + timeout
      loop do
        responce = @rax.servers.get(instance_id)
        status = responce["status"]
        puts "Status: #{status}"
        break if status && status == st
        if timeout?(try_until)
          raise "Failed to discover Instance with id: #{instance_id} within #{timeout} seconds."
        else
          sleep 5
        end
      end
    end

    def ModifyInstanceAttribute(instance_id, new_instance_type)
      @rax.resize_server(instance_id, new_instance_type || "3")
    end

    def scale_up(instance)
      wait_until(instance_id)
      ModifyInstanceAttribute(instance_id)
      w.wait_until(instance_id, "VERIFY_RESIZE")
      DescribeInstance(instance_id)
    end

    def TerminateInstance(instance_id)
      puts "Terminating"
      pp @rax.servers.get(instance_id).destroy
    end

    def timeout?(try_until)
      Time.now > try_until
    end
  end
end