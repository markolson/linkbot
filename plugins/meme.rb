##
# Generate memes using http://memegenerator.net

require 'json'

class Meme < Linkbot::Plugin

  def initialize
    register :regex => /!meme(.*)/
    help <<HELP
!meme, Get random meme image
!meme --help, Get this message...
!meme --list, List all supported memes
!meme MEME line1[; line2], Create a meme image, MEME can be upper or lowercase
HELP
  end

  @@meme_regex = Regexp.new(/^!meme([ ](--list|--help|[A-Za-z0-9_]+)([ ].*)?)?$/)

  ##
  # Sometimes your meme will have an error, fix it!
  class Error < RuntimeError; end

  ##
  # We have some generators up-in-here

  GENERATORS = Hash.new do |_, k|
    raise Error, "Unknown meme generator #{k}"
  end

  ##
  # For creating advice-dog type meme images.
  # These can accept up to two lines of text
  def self.advice_dog name, id, template_name, image_id, first_line = nil
    template = [id, 'AdviceDogSpinoff', template_name, image_id, first_line]
    template.compact

    GENERATORS[name] = template
  end

  # keep generators in alphabetical order
  advice_dog 'AFATHER',         111,    'High Expectations Asian Father', 1436
  advice_dog 'ALLTHE',          6013,   'X ALL THE THINGS',               1121885
  advice_dog 'BEAR',            92,     'Bear Grylls',                    89714
  advice_dog 'CHUCK',           5588,   'Chuck Norris',                   52021
  advice_dog 'CWOLF',           303,    'Courage Wolf',                   24
  advice_dog 'FA',              116,    'Forever Alone',                  142442
  advice_dog 'FBF',             3,      'Foul Bachelor Frog',             203
  advice_dog 'FRY',             305,    'Futurama Fry',                   84688
  advice_dog 'FWP',             340895, 'First World Problems',           2055789
  advice_dog 'GGG',             534,    'Good Guy Greg',                  699717
  advice_dog 'HKITTY',          360,    'Hipster Kitty',                  9351
  advice_dog 'HUSBAND',         1585,   'Internet Husband',               880976
  advice_dog 'IWOLF',           45,     'Insanity Wolf',                  20
  advice_dog 'JDUKE',           54,     'Joseph Ducreux',                 42
  advice_dog 'JOBS',            1210,   'Steve Jobs Says',                17967
  advice_dog 'LIMES',           1101,   'Limes Guy',                      15311
  advice_dog 'PEDOBEAR',        235,    'Pedobear',                       564288
  advice_dog 'RAPTOR',          17,     'Philosoraptor',                  984
  advice_dog 'SAP',             29,     'Socially Awkward Penguin',       983
  advice_dog 'SBM',             350,    'Successful Black Man',           1570
  advice_dog 'SCUMBAG',         142,    'Scumbag Steve',                  366130
  advice_dog 'SLOWPOKE',        526,    'Slowpoke',                       580816
  advice_dog 'SUCCESS',         121,    'Success',                        1031
  advice_dog 'TMIMITW',         74,     'The Most Interesting Man in the World', 2485
  advice_dog 'TROLLFACE',       68,     'Troll-Face',                     269
  advice_dog 'WONKA',           542616, 'Willy Wonka',                    2729805
  advice_dog 'YODAWG',          79,     'Yo Dawg Xzibit',                 108785
  advice_dog 'YUNO',            2,      'Y-U-NO',                         166088,         'Y U NO'
  # keep generators in alphabetical order

  ##
  # Looks up generator name
  def GENERATORS.match(name)
    # TODO  meme Y U NO DEMETAPHONE?
    return self[name] if has_key? name
    matcher = Regexp.new(name, Regexp::IGNORECASE)
    _, generator = find { |k,v| matcher =~ k || v.grep(matcher).any? }
    generator || self[name] # raises the error if generator is nil
  end

  ##
  # Generates links for +generator+
  def new_generator generator
    @template_id, @template_type, @generator_name, @image_id, @default_line = GENERATORS.match generator
  end

  ##
  # Generates a meme with +line1+ and +line2+.  For some generators you only
  # have to supply one line because the first line is defaulted for you.
  def generate text
    url = URI.parse 'http://memegenerator.net/Instance/CreateOrEdit'
    res = nil
    location = nil

    # Prepend the default line if this meme has one and we only had 1 text input
    text.unshift @default_line if @default_line and text.size <= 1

    raise Error, "Two lines are required for #{@generator_name}" unless text.size > 1

    url = URI.parse 'http://memegenerator.net/create/instance'
    res, location = nil, nil

    post_data = {
      'generatorID' => @template_id,
      'imageID' => @image_id,
      'text0' => text[0],
      'text1' => text[1],
      'languageCode' => 'en'
    }

    Net::HTTP.start url.host do |http|
      post = Net::HTTP::Post.new url.path
      post.set_form_data post_data

      res = http.request post

      id = res['Location'].split('/').last.to_i
      Linkbot.log.debug "Meme plugin: id == #{id}"
      return "http://images.memegenerator.net/instances/400x/#{id}.jpg"
    end
  end

  def help_list
    out = ""

    GENERATORS.sort.each_with_index do |(command, (id, type, name, _)), index|
      out += "%s [ %s ] " % [command, name]
      out += "--- " unless (index % 3) == 2 or index == GENERATORS.size - 1
      out += "\n" if (index % 3) == 2
    end
    out
  end

  def help_text; HELP_TEXT; end

  def on_message(message, matches)

    lines = message.body.scan(@@meme_regex)
    # First group will be the entire line
    # Second group will be --list or meme
    # Third group will be the one or two lines of meme text

    unless lines[0].nil?
      command = lines[0][1].strip unless lines[0][1].nil?

      return help_list if command == "--list"
      return help_text if command == "--help"

      #No command given, just try and get a random meme image from top 1000
      if lines[0][1].nil? and lines[0][2].nil?
        index = rand(1000)
        url = URI.parse "http://version1.api.memegenerator.net/Instances_Select_ByPopular?languageCode=en&pageIndex=#{index}&pageSize=1&urlName="
        res = Net::HTTP.get_response(url)

        return "MemeGenerator is herpin and derpin..." if res.code == '503'
        return "MemeGenerator blows..." if res.code == '500'

        body = JSON(res.body)
        id = body['result'][0]['instanceID']
        meme = body['result'][0]['displayName']

        return ["http://images.memegenerator.net/instances/400x/#{id}.jpg", meme]
      end

      begin
        meme = new command
        text = lines[0][2].split(';').map {|t| t.strip}
        return meme.generate text
      rescue Exception => e
        Linkbot.log.error "Meme plugin: #{e}"
        Linkbot.log.error e.backtrace.join("\n")
        user_name = message.user_name.split.first
        return "ZOMG, what happened?! #{user_name}, you broke all the memes!"
      end

    else
      return "Unknown command"
    end
  end

end
