class Commit < Linkbot::Plugin

  def initialize
    register :regex => /^!commit$/i
    help "!commit - get a random commit message"
  end

  def on_message(message, matches)
    url = URI.parse('http://whatthecommit.com/index.txt')
    res = Net::HTTP.get(url)
    '"%s"' % res.gsub("\n", '')
  end

end
