class Search < Linkbot::Plugin
  Linkbot::Plugin.register('search', self,
    {
      :message => {:regex => Regexp.new('!search (.*)'), :handler => :on_message, :help => :help}
    }
  )
  
  def self.on_message(user, message, matches, msg)
    search = matches[0]
    rows = nil
    mess = ""
    rows = Linkbot.db.execute('select l.url,u.username,l.dt from links l, users u where l.url like ? and l.user_id = u.user_id order by l.dt desc limit 10', "%#{search}%")
    i = 1
    if rows.length > 0
      rows.each {|row| mess = mess + "#{i}. #{row[0]} (#{row[1]} #{::Util.ago_in_words(Time.now, Time.at(row[2]))})\n"; i = i + 1}
    else
      mess = "No links"
    end
    [mess]
  end
  
  def self.help
    "!search query - search for links that you think should be dupes"
  end
end