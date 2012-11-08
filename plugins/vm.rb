require 'net/http'
require 'uri'
require 'optparse'

class Vm < Linkbot::Plugin
  
  Linkbot::Plugin.register('vm', self,
    {
      :message => {:regex => /!vm (.+)/, :handler => :on_message, :help => :help}
    }
  )
  
  def self.on_message(message, matches) 
    if Linkbot::Config["plugins"]["vm"].nil? || Linkbot::Config["plugins"]["vm"]["webhook"].nil?
      return "The vm plugin must be configured for use"
    end

    full_command = matches[0]
    args = full_command.split(" ").map{|e| e.strip}
    
    options = {
      :memory => 4096,
      :disk => 100,
      :cpu => 1,
      :runlist => nil,
      :env => "branch-vm"
    }
    o = OptionParser.new do |opts|
      opts.banner = "Usage: vm-manage [options]"
      opts.on("-r", "--chef-runlist RUNLIST", "Initialize with the provided chef runlist. Default is empty.") do |v|
        options[:runlist] = v
      end
      opts.on("-e", "--chef-environment ENVIRONMENT", "Initialize with the provided chef environment. Default is branch-vm.") do |v|
        options[:env] = v
      end
      opts.on("-m", "--memory N", Integer, "Size of VM memory (in GB). Default is 4.") do |v|
        options[:memory] = v * 1024
      end
      opts.on("-D", "--disk N", Integer, "Size of VM disk (in GB). Default is 100.") do |v|
        options[:disk] = v
      end
      opts.on("-c", "--cpu N", Integer, "Number of virtual CPUs. Default is 1.") do |v|
        options[:cpu] = v
      end
    end
    o.parse(args)
    
    message = ''
    
    case args[0]
    when "create"
      return "The virtual machine name must be supplied" if args[1].nil?
      url = "#{Linkbot::Config["plugins"]["vm"]["webhook"]}/vm-manage/create/#{args[1]}?runlist=#{options[:runlist]}&env=#{options[:env]}&disk=#{options[:disk]}&cpu=#{options[:cpu]}&memory=#{options[:memory]}"
      uri = URI.parse(url)
      Net::HTTP.get_response(uri)
    when "destroy"
      return "The virtual machine name must be supplied" if args[1].nil?
      uri = URI.parse("#{Linkbot::Config["plugins"]["vm"]["webhook"]}/vm-manage/destroy/#{args[1]}")
      Net::HTTP.get_response(uri)
    when "list"
      url = "#{Linkbot::Config["plugins"]["vm"]["webhook"]}/vm-manage/list"
      uri = URI.parse("#{Linkbot::Config["plugins"]["vm"]["webhook"]}/vm-manage/list")
      puts url
      resp = Net::HTTP.get_response(uri)
      puts resp
    when "help"
      message = []
      message << "The available commands are:"
      message << "  !vm create <vm name> [options] - Create a new virtual machine"
      message << "  !vm destroy <vm name> - Destroy an existing virtual machine"
      message << "  !vm list - List currently managed virtual machines"
      message << "  !vm help - This message"
      message << "Available options for the 'create' command are:"
      
      help_options = o.help.split("\n")
      help_options.shift
      message = message + help_options
    end
    
    message
  end
  
  def self.help
    "!vm [options] - Manage virtual environment. '!vm help' for help."
  end
end

