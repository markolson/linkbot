require 'date'
require 'octokit'

class UserNotFoundException < Exception
end

class GroupNotFoundException < Exception
end

class Groups < Linkbot::Plugin
  Linkbot::Plugin.register('group', self, {
    :message => {:regex => /!group (\w+)(.*)|#([\w_\-]+)/, :handler => :on_message, :help => :help}
  })

  def self.list_groups()
    groups = Linkbot.db.execute("SELECT groupname FROM groups")
    return [groups.join("\n")]
  end

  def self.addgroup(args)
    rows = Linkbot.db.execute("SELECT ifnull(max(group_id), 0) FROM groups")
    id = rows[0][0]
    Linkbot.db.execute("INSERT INTO groups (group_id, groupname) VALUES (?, ?)", id, args[0])
    ["added group #{args[0]}"]
  end

  def self.remgroup(args)
    Linkbot.db.execute("DELETE FROM groups WHERE groupname=?", args[0])
    ["deleted group #{args[0]}"]
  end

  def self.find_group(groupname)
    groups = Linkbot.db.execute("SELECT group_id FROM groups WHERE groupname=?", groupname)
    if groups.length == 0
      raise GroupNotFoundException, "Unable to find group <#{groupname}>"
    end

    groups[0][0]
  end

  def self.find_user(username)
    users = Linkbot.db.execute("SELECT user_id FROM users WHERE username LIKE ?", "%#{username}%")
    if users.length == 0
      raise UserNotFoundException, "Unable to find user <#{username}>"
    end

    users[0][0]
  end

  def self.adduser(args)
    user = args[0]
    group = args[1]

    begin
      user_id = find_user(user)
      group_id = find_group(group)
    rescue UserNotFoundException, GroupNotFoundException => e
      return [e.message]
    end

    Linkbot.db.execute("INSERT INTO groups_users (user_id, group_id) VALUES (?, ?)", user_id, group_id)
    ["added #{user} to #{group}"]
  end

  def self.list_users(args)
    if not args[0]
      users = Linkbot.db.execute("SELECT username FROM users")
    else
      begin
        group_id = find_group(args[0])
      rescue GroupNotFoundException => e
        return [e.message]
      end

      users = Linkbot.db.execute("SELECT username FROM users, groups_users WHERE users.user_id=groups_users.user_id AND groups_users.group_id=?", group_id)
    end

    if users.empty?
      []
    else
      [users.join("\n")]
    end
  end

  def self.remuser(args)
    user = args[0]
    group = args[1]

    begin
      user_id = find_user(user)
      group_id = find_group(group)
    rescue UserNotFoundException, GroupNotFoundException => e
      return [e.message]
    end

    Linkbot.db.execute("DELETE FROM groups_users WHERE user_id=? AND group_id=?", user_id, group_id)
    ["Removed user #{user} from group #{group}"]
  end

  def self.notify(groups, roster)
    group_ids = []
    response = []

    groups.each do |group|
      begin
        group_ids << find_group(group)
      rescue GroupNotFoundException => e
        response << "Could not find group #{group}"
      end
    end

    return response if group_ids.empty?

    puts group_ids
    users = Linkbot.db.execute("SELECT users.user_id FROM users, groups_users WHERE users.user_id=groups_users.user_id AND group_id IN (?)", group_ids)
    mentions = []
    users.each do |user|
      user = user[0]
      puts "searching user #{user}"
      mention = roster.find {|id,r| r.jid.to_s.split('@')[0] == user}
      mention = mention[1].attributes["mention_name"]
      if mention
        puts "found user #{mention}"
        mentions << "@#{mention}"
      end
    end


    if users.empty?
      []
    else
      response << [mentions.join(" ")]
    end

    response.flatten
  end

  def self.on_message(message, matches)
    command = matches[0]
    args = matches[1]
    if args
      args = args.split(",").map {|x| x.strip }
    end
    group_mention = matches[2]

    if command == "add"
      return self.addgroup(args)
    elsif command == "rem"
      return self.remgroup(args)
    elsif command == "adduser"
      return self.adduser(args)
    elsif command == "remuser"
      return self.remuser(args)
    elsif command == "list"
      return self.list_groups
    elsif command == "listusers"
      return self.list_users(args)
    elsif command == "notify"
      return self.notify(args, message[:options][:roster].items)
    elsif group_mention
      return self.notify([group_mention], message[:options][:roster].items)
    elsif command.start_with? "help"
      return [%{!group list - show all groups
!group add <groupname> - add a group
!group rem <groupname> - remove a group
!group adduser <username>, <groupname> - add a user
!group remuser <username>, <groupname> - remove a user from a group
!group listusers [<group>] - list all users, optionally only the users in one group
!group notify <groupname>[,<groupname] - mention all users in a group. Alternate syntax: #<groupname>}]
    end

    [self.help]
  end

  def self.help
    "!group <command> <args> - interact with github. Use the help command for more."
  end

  if Linkbot.db.table_info('groups').empty?
    Linkbot.db.execute('CREATE TABLE groups (group_id INTEGER, groupname STRING)')
  end

  if Linkbot.db.table_info('groups_users').empty?
    Linkbot.db.execute('CREATE TABLE groups_users (user_id STRING, group_id INTEGER)');
  end
end
