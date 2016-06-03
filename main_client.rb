require 'json'
require_relative 'client'
require_relative 'configuration'

if ARGV.length < 1
  puts "Uso correto: ruby main_client.rb <servidor> <número de mensagens>"
  abort
end

server = ARGV[0]
client = Client.new(server,Configuration::PORT)

tweets_text = File.read(File.join(File.dirname(__FILE__), "tweets.json"))
tweets = JSON.parse(tweets_text)["tweets"]

if ARGV.length < 2
  client.messages = tweets
else
  n = ARGV[1].to_i
  if n < tweets.size
    client.messages = tweets[0..n-1]
  else
    repeat = n/tweets.size
    repeat.times { client.add_messages tweets }
    mod = n%tweets.size
    if mod != 0
      client.add_messages tweets[0..mod-1]
    end
  end
end
p client.messages
client.send_all
