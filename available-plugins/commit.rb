class Commit < Linkbot::Plugin

  def self.help
    "!commit - get a random commit message"
  end

  def self.on_message(message, matches)
    url = URI.parse('http://whatthecommit.com/index.txt')
    res = Net::HTTP.get(url)
    '"%s"' % res.gsub("\n", '')
  end

  Linkbot::Plugin.register('commit', self, {
    :message => {:regex => /^!commit$/i, :handler => :on_message, :help => :help}
  })
end
