class LastFm < Linkbot::Plugin
  @@config = Linkbot::Config["plugins"]["last_fm"]
  @@fm_regex = Regexp.new(/^!fm([ ](help$|users$|.+$|register[ ].+|remove[ ].+))?$/)
  @@recent_tracks = "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&api_key=#{@@config['key']}&format=json"

  if @@config
    Linkbot::Plugin.register('last_fm', self, {
      :message => {:regex => /!fm(.*)/, :handler => :on_message, :help => :help}
    })
  end

  def self.on_message(message, matches)
    output = ""
    input = message.body.scan(@@fm_regex)

    unless input[0].nil?
      #Get all recent tracks
      if input[0][0].nil?
        output = get_recent_tracks
      else
        command, username = input[0][0].strip.split

        if command == "help"
          output = self.help

        elsif command == "users"
          output = self.get_users

        #Register user?
        elsif command == "register"
          if username.nil?
            output = "No username provided."
          else
            output = register_user(username, message.user_name)
          end

        #Remove user?
        elsif command == "remove"
          output = unregister_user(message.user_name)

        #Get recent tracks for a user
        else
          output = get_recent_tracks(command)
        end
      end
    end

    output
  end

  def self.get_users
    users = Linkbot.db.execute("select username, last_fm_username from users where last_fm_username not null")
    users.map {|u| "#{u[0]} - #{u[1]}"}
  end

  def self.register_user(username, user)
    begin
      update = Linkbot.db.prepare('update users set last_fm_username = (?) where username = (?)')
      update.execute(username, user)
      output = "Registered/updated Last.fm username for #{user}."
    rescue SQLite3::Exception => e
      output = "Failed to register/update username for #{user}."
      puts e
    end
  end

  def self.unregister_user(user)
    begin
      update = Linkbot.db.prepare('update users set last_fm_username = null where username = (?)')
      update.execute(user)
      output = "Unregistered Last.fm username for #{user}."
    rescue SQLite3::Exception => e
      output = "Failed to unregister username for #{user}."
      puts e
    end
  end

  def self.get_recent_tracks(user=nil, from=nil)
    usernames = []
    if user
      users_query = Linkbot.db.prepare("select last_fm_username from users where lower(username) like (?)")
      results = users_query.execute("#{user.downcase}%")

      # Have to do this because results is a SQLite3::ResultSet.........
      results.each {|username| usernames << username}
      return "No user found by name #{user}." if usernames.empty?
    else
      usernames = Linkbot.db.execute("select last_fm_username from users where last_fm_username not null")
    end

    if usernames.empty?
      return "No Last.fm users registered."
    else
      recent = usernames.uniq.map do |u|
        url = "#{@@recent_tracks}&limit=1&user=#{u}"

        begin
          tracks = ActiveSupport::JSON.decode(open(url).read)
        rescue Exception => e
          return "Error retrieving tracks for #{u}."
        end

        track = tracks['recenttracks']['track']
        if track.is_a? Array
          track = track.first
          (track['date'] ||= {})['#text'] = "now playing"
        end
        "#{u}: #{track['name']} - #{track['artist']['#text']}, #{track['date']['#text']}"
      end

      return recent.join("\n")
    end
  end

  def self.help
    ["!fm, Get tracks currently being listened to...\n",
     "!fm <username>|<name>, Get track currently being listened to by user.\n",
     "!fm register <username>, Register/update your last.fm username with Linkbot.\n",
     "!fm remove <username>, Unregister your last.fm username from Linkbot.\n",
     "!fm users, Get the list of registered Last.fm users\n",
     "!fm help, Get this message...\n"].join
  end

end
