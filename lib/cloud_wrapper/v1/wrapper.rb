module CloudWrapper
  module Instance
    class WrapperBase < Instance
      def initialize(cloud, nickname, options)
        super(cloud, nickname, options)
        puts("DEBUG: V1 CloudWrapper::Instance::WrapperBase.initialize is up with options #{options.inspect}")
      end

      def knife_local_list_nodes
         #TBD
      end

      def knife_local_destroy_node
         #TBD
      end


    end
  end
end

