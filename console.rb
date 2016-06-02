require 'socket'
require 'json'
require_relative 'client'
require_relative 'configuration'

if ARGV.length != 1
  puts "Uso correto: ruby main_server.rb <servidor>"
  abort
end

server = ARGV[0]

client = Client.new(server,Configuration::PORT)

commands = [{:cmd => '\q', :desc => "Parar o servidor"}, 
            {:cmd => '\s', :desc => "Imprimir status do servidor"},
            {:cmd => 'quit', :desc => "Sair do console"}]

loop do
  puts "prompt=>"
  cmd = $stdin.readline()
  case cmd.strip!
  when '\s'
    server = UDPSocket.new
    server.bind(Socket.gethostname, Configuration::ANSWER_PORT)
    client.send('status')
    text, sender = server.recvfrom(Configuration::BUF_SIZE)
    puts "Status: "
    clients = JSON.parse(text)
    p clients
  when '\q'
    client.send('end')
  when 'quit'
    break
  else
    puts "Comandos disponíveis: "
    commands.each do |c|
      puts c[:cmd]+" - "+c[:desc]
    end
  end
end