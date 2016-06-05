require 'socket'
require 'json'
require 'logger'
require 'optparse'
require 'io/console'
require_relative 'client'
require_relative 'configuration'

puts "-=NEYMAR CONSOLE=-"

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Uso correto: ruby console.rb [options]"

  opts.on("-s", "--server [NAME]", String, "Nome do servidor (obrigatório)") do |s|
    options[:server] = s
  end

  opts.on("-p", "--ping", "Verifica as máquinas disponíveis para usar como cliente") do |i|
    options[:ping] = i
  end

  opts.on("-h", "--help", "Imprime a ajuda") do |h|
    puts opts
    exit
  end
end

begin
  optparse.parse!
  mandatory = [:server]
  missing = mandatory.select{ |param| options[param].nil? }
  unless missing.empty?
    puts "Opções obrigratórias: #{missing.join(', ')}"
    puts optparse
    exit
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts optparse
  exit
end

file = File.open(File.join(File.dirname(__FILE__), 'client.log'), File::WRONLY | File::APPEND | File::CREAT)
log = Logger.new(file)
log.progname = "Console"

server_name = options[:server]

client = Client.new(server_name,Configuration::PORT)


commands = [{:cmd => '\s', :desc => "Imprimir status do servidor"},
            {:cmd => '\b', :desc => "Bombardear o servidor"},
            {:cmd => '\q', :desc => "Parar o servidor"},
            {:cmd => '\e', :desc => "Sair do console"}]

machines_text = File.read(File.join(File.dirname(__FILE__), "machines"))
machines = machines_text.split("\n")

unless options[:ping].nil?
  log.info {"Verificando disponibilidade de #{machines.size} possíveis clientes"}
  print "Verificando máquinas..."
  IO.popen("fping -u -t 250 -r 1 "+machines.join(' ')) do |f|
    f.each do |machine|
      machines.delete(machine.strip!)
      log.warn {"#{machine} não responde"}
    end
  end
  print "\r"
  log.info {"#{machines.size} máquinas disponíveis"}
end

def print_commands(commands)
  puts "Comandos disponíveis: "
  commands.each do |c|
    puts c[:cmd]+" - "+c[:desc]
  end
end

puts "Existem #{machines.size} máquinas disponíveis."
print_commands(commands)

num_machines = 0
num_messages = 61
loop do
  print "neymar-console=> "
  STDOUT.flush
  cmd = $stdin.readline()
  case cmd.strip!
  when '\s'
    server = UDPSocket.new
    server.bind(Socket.gethostname, Configuration::ANSWER_PORT)
    client.send('status')
    text, sender = server.recvfrom(Configuration::ANSWER_BUF_SIZE)
    server.close
    puts "Status: "
    clients = JSON.parse(text)
    log.debug {text}
    puts "O servidor recebeu mensagens de #{clients.size} máquinas."
    log.info {"STATUS: O servidor recebeu mensagens de #{clients.size} máquinas"}
    if clients.size < num_machines
      puts "(#{num_machines-clients.size} máquinas perderam todas as mensagens)"
      log.info {"#{num_machines-clients.size} máquinas perderam todas as mensagens"}
    end
    sum_out_of_order = 0
    sum_received = 0
    clients.each do |c|
      c["lost"] = num_messages-(c["received"])
      sum_received += c["received"]
      sum_out_of_order += c["out_of_order"]
      puts "#{c["name"]} enviou #{c["received"]} datagramas, teve #{c["lost"]} datagramas perdidos e #{c["out_of_order"]} datagramas desordenados."
    end
    puts "Porcentagem total de mensagens perdidas: #{(100-(sum_received.to_f/(num_messages*num_machines))*100).round(2)}%"
    log.info {"STATUS: Porcentagem total de mensagens perdidas: #{(100-(sum_received.to_f/(num_messages*num_machines))*100).round(2)}%" }
    puts "Porcentagem total de mensagens desordenadas: #{((sum_out_of_order.to_f/(num_messages*num_machines))*100).round(2)}%"
    log.info {"STATUS: Porcentagem total de mensagens desordenadas: #{((sum_out_of_order.to_f/(num_messages*num_machines))*100).round(2)}%"}
  when '\q'
    client.send('end')
  when '\b'
    puts "Quantas máquinas? (Max: #{machines.size})"
    begin
      num_machines = Integer($stdin.readline().strip!).abs
    rescue ArgumentError
    end

    if num_machines <= machines.size
      puts "Quantas mensagens? (por padrão 61)"
      begin
        num_messages = Integer($stdin.readline()).abs
      rescue ArgumentError
      end
      puts "Enviando #{num_machines*num_messages} mensagens de #{num_machines} clientes"
      log.info {"Enviando #{num_machines*num_messages} mensagens de #{num_machines} clientes"}
      user = ENV["USER"]
      puts "Entre com senha de #{user}:"
      pass = STDIN.noecho(&:gets).strip!
      main_client = "ruby "+Dir.pwd+"/main_client.rb #{server_name} #{num_messages}"
      puts "Criando clientes..."
      num_machines.times do |i|
        shooter = "./shooter.exp #{user} #{machines[i]} \"#{main_client}\""
        pid = spawn({"PASS"=>pass.strip}, shooter)
        Process.detach pid
        puts "Cliente criado em: #{machines[i]}"
        log.info {"Cliente criado em #{machines[i]}"}
      end
      log.info {"As mensagens foram enviadas"}
      STDOUT.flush
      print "\r"
    else
      puts "ERRO: número inválido de máquinas"
    end
  when '\e'
    break
  else
    puts "Comandos disponíveis: "
    commands.each do |c|
      puts c[:cmd]+" - "+c[:desc]
    end
  end
  print "\r"
end
