class Commit < Linkbot::Plugin

  register :regex => /^!commit$/i
  help "!commit - get a random commit message"

  def self.on_message(message, matches)
    url = URI.parse('http://whatthecommit.com/index.txt')
    res = Net::HTTP.get(url)
    '"%s"' % res.gsub("\n", '')
  end

end
