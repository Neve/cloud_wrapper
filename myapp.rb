# create/?c=openstack
# &n=chef-test-inst-3
# &f=9&i=c8dde561-a277-4cf2-85dd-802a82f47bde
# &ssh_pass=changeme1122
# TODO move params to cookies or html body

require File.dirname(__FILE__) + '/lib/cloud_wrapper'
require File.dirname(__FILE__) + '/helpers/common'
require 'sinatra'
require 'sinatra/contrib'

include CloudWrapper::Helper::Common
set :environment, :development


get '/' do
  "missing action route"
end

get '/:api_version/destroy' do
  "destroy instance with : #{params.inspect}"
  instance = CloudWrapper::Instance.factory(params[:cloud], params[:N], params)
  knife_out = instance.destroy(params[:N], options = params)
  quick_results = knife_run_output(knife_out)
  "#{quick_results}"
end

get '/:api_version/create' do
  instance = CloudWrapper::Instance.factory(params[:cloud], params[:api_version], params)
  knife_out = instance.create(params[:N], params)

  if params[:qr]
    sleep 2
    "#{knife_run_output(knife_out)}"
  else
    "#{knife_out} ## #{params.inspect}"
  end
end

get '/:api_version/create_c' do
  "value: #{params[:api_version]}"
  #instance = CloudWrapper::Instance.factory(params[:cloud], params[:N], params)
  #knife_out = instance.create(params[:N], params)

  #if params[:qr]
  #  sleep 2
  #  "#{knife_run_output(knife_out)}"
  #else
  #  "#{knife_out}"
  #end
end


get '/:api_version/list' do
  #instance = CloudWrapper::Instance.factory(params[:cloud], 'list', params)
  instance = CloudWrapper::Instance.factory(params[:cloud], params[:api_version] , params)
  "#{instance.list}"
end


get '/:api_version/status' do
  #TODO move this to Sinatra helper
  knife_out = params[:instance_name]
  stream(:keep_open) do |out|
    require 'pty'
    cmd = "tailf /var/log/cloud_wrapper/#{knife_out}"
    begin
      PTY.spawn(cmd) do |stdin, stdout, pid|
        begin
          # Do stuff with the output here. Just printing to show it works
          stdin.each do |line|
            out.close if line.include?('MAN_STOP')
            out << line + '<BR>'
          end
        rescue Errno::EIO
          puts "Errno:EIO error, but this probably just means " +
            "that the process has finished giving output"

        end
      end
    rescue PTY::ChildExited
      puts "The child process exited!"
      out.close
    end
  end


end