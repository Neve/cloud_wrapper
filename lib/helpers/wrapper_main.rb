module CloudWrapper
  module Helper
    module WrapperMain

      def get_config_vars(param_name)
        require 'yaml'
        fn = "#{File.dirname(__FILE__)}/../../config.yml"
        config = YAML::load(File.open(fn))
        return config[param_name]
      end

    end
  end
end
