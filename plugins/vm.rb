require 'net/http'
require 'uri'
require 'optparse'

class Vm < Linkbot::Plugin

  Linkbot::Plugin.register('vm', self,
    {
      :message => {:regex => /\A!vm (.+)/, :handler => :on_message, :help => :help}
    }
  )

  create_log(:vm)

  def self.on_message(message, matches)
    if Linkbot::Config["plugins"]["vm"].nil? || Linkbot::Config["plugins"]["vm"]["webhook"].nil?
      return "The vm plugin must be configured for use"
    end

    full_command = matches[0]
    log(:vm, full_command)
    args = full_command.split(" ").map{|e| e.strip}

    options = {
      :memory => 4,
      :disk => 100,
      :cpu => 1,
      :runlist => nil,
      :env => "vm"
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
        options[:memory] = v
      end
      opts.on("-D", "--disk N", Integer, "Size of VM disk (in GB). Default is 100.") do |v|
        options[:disk] = v
      end
      opts.on("-c", "--cpu N", Integer, "Number of virtual CPUs. Default is 1.") do |v|
        options[:cpu] = v
      end
    end
    o.parse!(args)

    message = ''

    case args[0]
    when "create"
      return "The virtual machine name must be supplied" if args[1].nil?
      url = "#{Linkbot::Config["plugins"]["vm"]["webhook"]}/vm-manage/create/#{args[1]}?runlist=#{options[:runlist]}&env=#{options[:env]}&disk=#{options[:disk]}&cpu=#{options[:cpu]}&memory=#{options[:memory]}"
      uri = URI.parse(url)
      Net::HTTP.get_response(uri)
    when "destroy"
      return "The virtual machine name must be supplied. Destruction cancelled." if args[1].nil?
      return "Request to destroy virtual machine '#{args[1]}' - to confirm, please enter !vm confirm #{args[1]}"
    when "confirm"
      return "The virtual machine name must be supplied. Destruction cancelled." if args[1].nil?
      old_message = @@message_logs[:vm][1]
      old_args = old_message.split(" ").map{|e| e.strip}
      o.parse!(old_args)
      if old_args[0] != "destroy"
        return "The previous command was not a destroy command."
      elsif old_args[1] != args[1]
        return "The VM names do not match. Destruction cancelled."
      else
        uri = URI.parse("#{Linkbot::Config["plugins"]["vm"]["webhook"]}/vm-manage/delete/#{args[1]}")
        Net::HTTP.get_response(uri)
      end
    when "list"
      url = "#{Linkbot::Config["plugins"]["vm"]["webhook"]}/vm-manage/list"
      uri = URI.parse(url)
      Net::HTTP.get_response(uri)
    when "snapshot"
      return "The virtual machine name must be supplied." if args[1].nil?
      url = "#{Linkbot::Config["plugins"]["vm"]["webhook"]}/vm/manage/snapshot/#{args[1]}/create"
      uri = URI.parse(url)
      Net::HTTP.get_response(uri)
    when "snapshot-list"
      return "The virtual machine name must be supplied." if args[1].nil?
      url = "#{Linkbot::Config["plugins"]["vm"]["webhook"]}/vm/manage/snapshot/#{args[1]}/list"
      uri = URI.parse(url)
      Net::HTTP.get_response(uri)
    when "snapshot-destroy"
      return "The virtual machine name must be supplied." if args[1].nil?
      return "The snapshot name must be supplied." if args[2].nil?
      url = "#{Linkbot::Config["plugins"]["vm"]["webhook"]}/vm/manage/snapshot/#{args[1]}/delete/#{args[2]}"
      uri = URI.parse(url)
      Net::HTTP.get_response(uri)
    when "snapshot-load"
      return "The virtual machine name must be supplied." if args[1].nil?
      return "The snapshot name must be supplied." if args[2].nil?
      url = "#{Linkbot::Config["plugins"]["vm"]["webhook"]}/vm/manage/snapshot/#{args[1]}/revert/#{args[2]}"
      uri = URI.parse(url)
      Net::HTTP.get_response(uri)
    when "help"
      m = []
      m << "The available commands are:"
      m << "  !vm create <vm name> [options] - Create a new virtual machine"
      m << "  !vm destroy <vm name> - Destroy an existing virtual machine (requires confirmation, see below)"
      m << "  !vm confirm <vm name> - Confirms the destruction of a virtual machine"
      m << "  !vm list - List currently managed virtual machines"
      m << "  !vm snapshot <vm name> - Create a new snapshot of a virtual machine"
      m << "  !vm snapshot-list <vm name> - List all snapshots for a virtual machine"
      m << "  !vm snapshot-destroy <vm name> <snapshot> - Destroy a snapshot for a virtual machine"
      m << "  !vm snapshot-load <vm name> <snapshot> - Load a snapshot for a virtual machine"
      m << "  !vm help - This message"
      m << "Available options for the 'create' command are:"

      help_options = o.help.split("\n")
      help_options.shift
      m = m + help_options
      message = [m.join("\n")]
    end

    message
  end

  def self.help
    "!vm [options] - Manage virtual environment. '!vm help' for help."
  end
end

