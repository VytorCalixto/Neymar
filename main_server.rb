require_relative 'client'
require_relative 'configuration'

if ARGV.length != 1
  puts "Uso correto: ruby main_server.rb <servidor>"
  abort
end

server = ARGV[0]

client = Client.new(server,Configuration::PORT)

commands = ['\q', '\s']

loop do
  puts "prompt=>"
  cmd = $stdin.readline()
  p cmd.strip!
  if commands.include? cmd
    if cmd == '\s'
      client.messages = ['status']
      client.send_all
    else
      client.messages = ['end']
      client.send_all
      break
    end
  else
    p commands
  end
end
