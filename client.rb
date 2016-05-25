require 'socket'

if ARGV.length != 3
  puts "Uso correto: ruby client.rb <mensagem> <servidor> <porta>"
  abort
end

message = ARGV[0]
server = ARGV[1]
port = ARGV[2]

s = UDPSocket.new
s.send(message, 0, server, port)