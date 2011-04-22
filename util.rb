module Util
  def self.ago_in_words(time1, time2)
    diff = time1.to_i - time2.to_i
    ago = ''
    if diff == 1
      ago = "#{diff} second ago"
    elsif diff < 60
      ago = "#{diff} seconds ago"
    elsif diff < 120
      ago = "a minute ago"
    elsif diff < 3600
      ago = "#{diff.to_i / 60} minutes ago"
    elsif diff < 7200
      ago = "an hour ago"
    elsif diff < 86400
      ago = "#{diff.to_i / 3600} hours ago"
    elsif diff < 172800
      ago = "yesterday"
    elsif diff < 604800
      ago = "#{diff.to_i / 86400} days ago"
    elsif diff < 1209600
      ago = "last week"
    else
      ago = "#{diff.to_i / 604800} weeks ago"
    end
    ago
  end
end