require 'socket'
require 'json'
require_relative 'client'
require_relative 'configuration'

if ARGV.length != 1
  puts "Uso correto: ruby console.rb <servidor>"
  abort
end

server = ARGV[0]

client = Client.new(server,Configuration::PORT)

commands = [{:cmd => '\q', :desc => "Parar o servidor"},
            {:cmd => '\s', :desc => "Imprimir status do servidor"},
            {:cmd => 'quit', :desc => "Sair do console"},
            {:cmd => '\t', :desc => 'Bombardeia o servidor'}]

machines_text = File.read(File.join(File.dirname(__FILE__), "machines"))
machines = machines_text.split("\n")

machines.delete_if do |m|
    ping = `ping -q -c 2 #{m}`
    if $?.exitstatus != 0
        true
    end
end

puts "Existem #{machines.size} máquinas disponíveis."

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
