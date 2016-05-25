require 'socket'
require_relative 'config'

if ARGV.length != 1
  puts "Uso correto: ruby server.rb <porta>"
  abort
end

port = ARGV[0]

server = UDPSocket.new
server.bind(nil, port)

loop do
  text, sender = server.recvfrom(Config::BUF_SIZE)
  puts text
  break if text == "quit"
end 