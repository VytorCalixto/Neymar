require 'socket'
require 'resolv'
require_relative 'configuration'

server = UDPSocket.new
server.bind(Socket.gethostname, Configuration::PORT)

p "Ouvindo..."
clients = {}
loop do
  text, sender = server.recvfrom(Configuration::BUF_SIZE)
  name = Resolv.getname(sender[3])
  clients[name] << text.split(' - ')[0] if clients.key? name
  puts "Recebi: "+text+" de "+Resolv.getname(sender[3])
  break if text == "end"
end 
p clients