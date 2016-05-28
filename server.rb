require 'socket'
require 'resolv'
require_relative 'configuration'

server = UDPSocket.new
server.bind(Socket.gethostname, Configuration::PORT)

p "Ouvindo..."
loop do
  text, sender = server.recvfrom(Configuration::BUF_SIZE)
  puts "Recebi: "+text+" de "+Resolv.getname(sender[3])
  break if text == "end"
end 