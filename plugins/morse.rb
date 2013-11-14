class Morse < Linkbot::Plugin

  Linkbot::Plugin.register('morse', self, {
    :message => {:regex => /\A[\s\.-]+\z/i, :handler => :on_message}
  })

  def self.on_message(message, matches)
    morse_map = {
      '.-'   => 'A', '-...' => 'B', '-.-.' => 'C', '-..'  => 'D', '.'    => 'E',
      '..-.' => 'F', '--.'  => 'G', '....' => 'H', '..'   => 'I', '.---' => 'J',
      '-.-'  => 'K', '.-..' => 'L', '--'   => 'M', '-.'   => 'N', '---'  => 'O',
      '.--.' => 'P', '--.-' => 'Q', '.-.'  => 'R', '...'  => 'S', '-'    => 'T',
      '..-'  => 'U', '...-' => 'V', '.--'  => 'W', '-..-' => 'X', '-.--' => 'Y',
      '--..' => 'Z'
    }

    translation = message.body.split(' ').map {|code| morse_map[code]}.join
    "Translated: #{translation}"
  end

end

