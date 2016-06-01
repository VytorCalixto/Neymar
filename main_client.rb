require_relative 'client'
require_relative 'configuration'
require 'json'

if ARGV.length != 1
  puts "Uso correto: ruby main_client.rb <servidor>"
  abort
end

server = ARGV[0]

client = Client.new(server,Configuration::PORT)
tweets = File.read(File.join(File.dirname(__FILE__), "tweets.json"))
client.messages = JSON.parse(tweets)["tweets"]
p client.messages
client.send_all
