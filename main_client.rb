require_relative 'client'
require_relative 'configuration'

if ARGV.length != 1
  puts "Uso correto: ruby artillery.rb <servidor>"
  abort
end

server = ARGV[0]

client = Client.new(server,Configuration::PORT)
client.messages = ["5 - HU3", "4 - HUE","3 - LOL","2 - hue","1 - lol"] #TODO
client.send_all