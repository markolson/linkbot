# encoding: UTF-8

class Fakename < Linkbot::Plugin

  def initialize
    help "!fakename - generate a fake name"
    register :regex => /!fakename/
  end

  def on_message(message, matches)
    firstnames = ['Alberto','Alejandro','Alfonso','Andres','Aníbal','Antonio','Ariel','Armando','Benito','Bernardo','Carlos','Carmelo','Cesar','Dario','Diego','Eduardo','Efraín','Emilio','Enrique','Ernesto','Esteban','Fabricio','Federico','Feliciano','Felipe','Fernando','Gilberto','Guillermo','Gustavo','Ignacio','Inigo','Jaime','Javier','Jorge','José','José María','José Enrique','Juan','Julio','Julio Cesar','Leandro','Lorenzo','Luis','Manolo','Manuel','Marcelino','Marcelo','Marcos','Mariano','Mario','Mateo','Maximiliano','Miguel Ángel','Narciso','Omar','Osvaldo','Pablo','Paco','Pascual','Pepe','Raphael','Raul','Ricardo','Rolando','Salvador','Sandro','Santiago','Silvestre','Víctor','Victorino']
    lastnames = ['Adventure','Badass','Calamity','Catastrophe','Clandestine','Covert','Death','Distress','Dynamite','Evil','Furtive','Gamble','Hazard','Jeopardy','Kill','Menace','Peril','Risk','Scourge','Sly','Smash','Stealth','Threat','Trouble','Verboten','Violence']

    "#{firstnames.sample} #{lastnames.sample}"
  end

end
