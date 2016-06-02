require 'socket'
require 'json'
require 'logger'
require_relative 'client'
require_relative 'configuration'

if ARGV.length != 1
  puts "Uso correto: ruby console.rb <servidor>"
  abort
end

file = File.open('neymar.log', File::WRONLY | File::APPEND)
log = Logger.new(file)

server = ARGV[0]

client = Client.new(server,Configuration::PORT)

commands = [{:cmd => '\q', :desc => "Parar o servidor"},
            {:cmd => '\s', :desc => "Imprimir status do servidor"},
            {:cmd => 'quit', :desc => "Sair do console"},
            {:cmd => '\b', :desc => 'Bombardeia o servidor'}]

machines_text = File.read(File.join(File.dirname(__FILE__), "machines"))
machines = machines_text.split("\n")

log.info('Console') {"Verificando disponibilidade de #{machines.size} possíveis clientes"}
print "Verificando máquinas"
machines.delete_if do |m|
    print "."
    $STDOUT.flush
    log.debug('Console') {"Ping em #{m}"}
    ping = `ping -q -c 2 #{m}`
    if $?.exitstatus != 0
        log.debug('Console') {"#{m} não responde"}
        true
    end
end
log.info('Console') {"#{machines.size} máquinas disponíveis"}

puts "Existem #{machines.size} máquinas disponíveis."

loop do
  puts "neymar-console=>"
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
  when '\b'
    puts "Quantas máquinas? (Max: #{machines.size})"
    num_machines = 0
    begin
      num_machines = Integer($stdin.readline().strip!).abs
    rescue ArgumentError
    end
    if num_machines <= machines.size
      puts "Quantas mensagens? (por padrão 61)"
      num_messages = 61
      begin
        num_messages = Integer($stdin.readline()).abs
      rescue ArgumentError
      end
      puts "Enviando #{num_machines*num_messages} mensagens de #{num_machines} clientes."
    else
      puts "ERRO: número inválido de máquinas"
    end
  when 'quit'
    break
  else
    puts "Comandos disponíveis: "
    commands.each do |c|
      puts c[:cmd]+" - "+c[:desc]
    end
  end
end
