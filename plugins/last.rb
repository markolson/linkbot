class Last < Linkbot::Plugin
    def self.on_message(message, match)
      count = match[0] || 5
      rows = nil
      mess = ""
      if match[1]
        rows = Linkbot.db.execute("select l.url,l.dt from links l, users u where u.username='#{match[1]}' and u.user_id = l.user_id order by l.dt desc limit #{count}")
        i = 1
        if rows.length > 0
          rows.each {|row| mess = mess + "#{i}. #{row[0]} (#{::Util.ago_in_words(Time.now, Time.at(row[1]))})\n"; i = i + 1}
        else
          mess = "No links from user '#{match[1]}'"
        end
      else
        rows = Linkbot.db.execute("select l.url,l.dt,u.username,u.showname from links l, users u where l.user_id = u.user_id order by l.dt desc limit #{count}")
        i = 1
        if rows.length > 0
          rows.each {|row| 
            username = (row[3].nil? || row[3] == '') ? row[2] : row[3]
            mess = mess + "#{i}. #{row[0]} (#{username} #{::Linkbot::Util.ago_in_words(Time.now, Time.at(row[1]))})\n"; i = i + 1
          }
        else
          mess = "No links"
        end
      end
      mess

    end

    def self.help
      "!last (num) (nick) - Displays the last links provided by users. (num) is optional and defaults to 5; (nick) is optional and returns only links from the specified user."
    end

    Linkbot::Plugin.register('last', self,
      {
        :message => {:regex => /!last(?: (\d+))?(?: (.*))?/, :handler => :on_message, :help => :help},
        :"direct-message" => {:regex => /!last(?: (\d+))?(?: (.*))?/, :handler => :on_message, :help => :help}
      }
    )
end
