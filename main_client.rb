require_relative 'client'
require_relative 'configuration'
require 'json'

if ARGV.length < 1
  puts "Uso correto: ruby main_client.rb <servidor> <número de mensagens>"
  abort
end

server = ARGV[0]
n = ARGV[1].to_i
client = Client.new(server,Configuration::PORT)

tweets_text = File.read(File.join(File.dirname(__FILE__), "tweets.json"))
tweets = JSON.parse(tweets_text)["tweets"]

if n < tweets.size
  client.messages = tweets[0..n-1]
else
  repeat = n/tweets.size
  repeat.times { client.messages.concat tweets }
  mod = n%tweets.size
  if mod != 0
    client.messages.concat tweets[0..mod]
  end
end
    
p client.messages
client.send_all
