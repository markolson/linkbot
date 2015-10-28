require 'rubygems'
require 'open-uri'
require 'json'

class Weather < Linkbot::Plugin

  def initialize
    register :regex => Regexp.new('^!weather(?: (\d\d\d\d\d))?(?: (\d\d?)d)?')
    help "!weather (zip) (10d) - Get your weather on."
  end

  @@iconmap = {
    "chanceflurries" => "❄️",
     "chancerain" => "💧",
     "chancesleet" => "💧",
     "chancesnow" => "❄️",
     "chancetstorms" => "⚡️",
     "clear" => "☀️",
     "cloudy" => "☁️",
     "flurries" => "❄️",
     "fog" => "☁️",
     "hazy" => "☁️",
     "mostlycloudy" => "⛅️",
     "mostlysunny" => "⛅️",
     "partlycloudy" => "⛅️",
     "partlysunny" => "⛅️",
     "sleet" => "💧",
     "rain" => "💧",
     "snow" => "❄️",
     "sunny" => "☀️",
     "tstorms" => "⚡️"
   }


   def on_message(message, matches)
     if Linkbot::Config['plugins']['weather'].nil? ||
        Linkbot::Config['plugins']['weather']['key'].nil? ||
        Linkbot::Config['plugins']['weather']['icons'].nil? ||
        Linkbot::Config['plugins']['weather']['default-zip'].nil?
        return ["The weather plugin must be configured for use"]
    end

    zip = Linkbot::Config['plugins']['weather']['default-zip']
    days = 5

    if matches[0]
      zip = matches[0]
    end
    if matches[1]
      days = matches[1].to_i
    end

    days = 10 if days > 10

     # Fetch the city name from google:
     url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{zip}&sensor=true"
     doc = JSON.parse(open(url).read)
     messages = []
     if doc["results"].length == 0
       messages << "(dealwithit) Could not find ZIP Code #{zip}"
     else
       city_parts = doc["results"][0]["formatted_address"].split(",")
       city = "#{city_parts[0]}, #{city_parts[1].split(" ")[0]}"
       message = "Forecast for #{city}: "

       url = "http://api.wunderground.com/api/#{Linkbot::Config['plugins']['weather']['key']}/forecast10day/q/CA/#{zip}.json"
       doc = JSON.parse(open(url).read)

       days = doc["forecast"]["simpleforecast"]["forecastday"][0,days].map do |day|
         m = "#{day["date"]["weekday_short"]}: "
         m = m + (Linkbot::Config['plugins']['weather']['icons'] == true ? "#{@@iconmap[day["icon"]]} " : "#{day["conditions"]} ")
         m = m + "#{day["high"]["fahrenheit"]}/#{day["low"]["fahrenheit"]}"
         m
       end

       message = message + days.join(" | ")
       messages << message
     end
     messages
   end
end
