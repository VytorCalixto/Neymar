require 'socket'
require 'resolv'
require_relative 'configuration'
require_relative 'server_client'

server = UDPSocket.new
server.bind(Socket.gethostname, Configuration::PORT)

p "Ouvindo..."
clients = {}
loop do
  text, sender = server.recvfrom(Configuration::BUF_SIZE)
  name = Resolv.getname(sender[3])
  clients[name] = ServerClient.new(name) if !clients.key? name
  begin
    clients[name].addMsg(Integer(text.split(' - ')[0]))
  rescue ArgumentError
  end
  puts "Recebi: "+text+" de "+Resolv.getname(sender[3])
  break if text == "end"
end
p clients

clients.each do |k, c|
  puts c.status
end
