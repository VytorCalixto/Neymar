require 'socket'
require 'resolv'
require 'json'
require 'logger'
require_relative 'configuration'
require_relative 'server_client'
require_relative 'client'

file = File.open('server.log', File::WRONLY | File::APPEND | File::CREAT)
log = Logger.new(file)
log.progname = "Servidor"

server = UDPSocket.new
server.bind(Socket.gethostname, Configuration::PORT)
log.info {"Servidor conectado"}
log.info {"Ouvindo..."}

p "Ouvindo..."
clients = []
loop do
  text, sender = server.recvfrom(Configuration::BUF_SIZE)

  break if text == "end"

  name = Resolv.getname(sender[3])

  if text == "status"
    client = Client.new(name,Configuration::ANSWER_PORT)
    client.send(JSON.generate(clients))
    log.info {"Enviando status atual"}
  else
    i = clients.index {|c| c.name == name }
    if i.nil?
      i = clients.size
      clients << ServerClient.new(name)
    end
    begin
      clients[i].add_msg(Integer(text.split(' - ')[0]))
    rescue ArgumentError
    end
    # puts "Recebi: "+text+" de "+Resolv.getname(sender[3])
    log.debug {"Recebi: "+text+" de "+Resolv.getname(sender[3])}
  end
end
log.info {"Servidor encerrado"}
p clients

puts clients.size.to_s + " clientes enviaram datagramas."
clients.each do |c|
  puts c.status
  log.info {"Cliente #{c.name}, mensagens recebidas: #{c.messages}"}
end
