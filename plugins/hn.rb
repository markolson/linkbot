class HackerNews < Linkbot::Plugin
  Linkbot::Plugin.register('hn', self,
    {
      :message => {:regex=> /!hn/, :handler=> :on_message, :help => :help}
    }
  )

  def self.on_message(message, matches)
    begin
      site = "https://news.ycombinator.com/newcomments"
      doc = Hpricot(open(site).read)
      comments = doc.search("td.default")
      rand_comment = comments[rand(comments.length)]

      user = rand_comment.search("a")[0].inner_text
      comment = rand_comment.search("font")[0].inner_text
      "#{comment} - #{user}"
    rescue
      "Stupid Hacker News is down."
    end
  end

  def self.help
    "!hn - Random recent HN comment"
  end
end
