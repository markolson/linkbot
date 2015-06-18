class LastFm < Linkbot::Plugin
  @@config = Linkbot::Config["plugins"]["last_fm"]

  if @@config
    @@fm_regex = Regexp.new(/^!fm([ ](help$|users$|.+$|register[ ].+|remove[ ].+))?$/)
    @@recent_tracks = "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&api_key=#{@@config['key']}&format=json"

    register :regex => /!fm(.*)/, :periodic => {:handler => :periodic}
    help "!fm, Get tracks currently being listened to...\n!fm <username>|<name>, Get track currently being listened to by user.\n!fm register <username>, Register/update your last.fm username with Linkbot.\n!fm remove, Unregister your last.fm username from Linkbot.\n!fm users, Get the list of registered Last.fm users\n!fm help, Get this message...\n"
  end

  def self.api_send(message)
    return if message.nil?

    message = CGI.escape(message)
    from = @@config['hipchat_from'] || "Last.fm"
    begin
      url = "https://api.hipchat.com/v1/rooms/message?" \
          + "auth_token=#{@@config['hipchat_api_token']}&" \
          + "message=#{message}&" \
          + "room_id=#{@@config['hipchat_room']}&" \
          + "from=#{from}"

      puts "sending message to hipchat url #{url}"
      open(url)
    rescue => e
      puts e.inspect
      puts e.backtrace.join("\n")
    end
  end

  def self.periodic
    output = get_recent_tracks(:now_playing => true)
    output.each {|m| api_send(m) unless m.nil?}
    {:messages => [], :options => {}}
  end

  def self.on_message(message, matches)
    output = ""
    input = message.body.scan(@@fm_regex)

    unless input[0].nil?
      #Get all recent tracks
      if input[0][0].nil?
        output = get_recent_tracks.join("\n")
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
          output = get_recent_tracks(command).join("\n")
        end
      end
    end

    output
  end

  def self.get_users
    users = Linkbot.db.execute("select username, last_fm_username from users where last_fm_username not null")
    users.map {|u| "#{u[0]} - #{u[1]}"}.join("\n")
  end

  def self.register_user(username, user)
    begin
      update = Linkbot.db.prepare('update users set last_fm_username = (?) where username = (?)')
      update.execute(username, user)
      output = "Registered/updated Last.fm username for #{user}."
    rescue SQLite3::Exception => e
      output = "Failed to register/update username for #{user}."
      puts e
      puts e.backtrace
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
      puts e.backtrace
    end
  end

  def self.get_recent_tracks(options = {})
    user = options[:user] || nil
    from = options[:from] || nil
    now  = options[:now_playing] || false

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
        url = "#{@@recent_tracks}&limit=1&user=#{u[0]}"

        current = ""
        if now
          current = Linkbot.db.execute("select now_playing from users where last_fm_username = ?", u[0])[0][0] || ":("
        end
        begin
          tracks = ActiveSupport::JSON.decode(open(url).read)

          track = tracks['recenttracks']['track']
          if track.is_a? Array
            track = track.first
            (track['date'] ||= {})['#text'] = "now playing"
          end

          # Set last/most recently played track
          update = Linkbot.db.prepare('update users set now_playing = (?) where last_fm_username = (?)')
          update.execute("#{track['name']} - #{track['artist']['#text']}", u[0])

          out = "#{u[0]}: #{track['name']} - #{track['artist']['#text']}, #{track['date']['#text']}"

          next if now and out.include?(current)
          next if now and track['date']['#text'] != 'now playing'

          out
        rescue
          "#{u[0]}: Error retrieving track data..."
          puts $!
          puts $!.backtrace
        end
      end

      return recent
    end
  end

end
