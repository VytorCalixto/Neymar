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

file = File.open(File.join(File.dirname(__FILE__), 'neymar.log'), File::WRONLY | File::APPEND)
log = Logger.new(file)
log.progname = "Console"

server = options[:server]

client = Client.new(server,Configuration::PORT)


commands = [{:cmd => '\q', :desc => "Parar o servidor"},
            {:cmd => '\s', :desc => "Imprimir status do servidor"},
            {:cmd => 'quit', :desc => "Sair do console"},
            {:cmd => '\b', :desc => 'Bombardeia o servidor'}]

machines_text = File.read(File.join(File.dirname(__FILE__), "machines"))
machines = machines_text.split("\n")

unless options[:ping].nil?
  log.info {"Verificando disponibilidade de #{machines.size} possíveis clientes"}
  print "Verificando máquinas"
  machines.delete_if do |m|
      print "."
      STDOUT.flush
      log.debug {"Ping em #{m}"}
      ping = `ping -q -c 1 -W 1 #{m} > /dev/null`
      if $?.exitstatus != 0
        log.warn {"#{m} não responde"}
        true
      end
  end
  print "\r"
  log.info {"#{machines.size} máquinas disponíveis"}
end

puts "Existem #{machines.size} máquinas disponíveis."

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
      puts "Enviando #{num_machines*num_messages} mensagens de #{num_machines} clientes"
      log.info {"Enviando #{num_machines*num_messages} mensagens de #{num_machines} clientes"}
      user = ENV["USER"]
      puts "Entre com senha de #{user}:"
      pass = STDIN.noecho(&:gets).strip!
      main_client = "ruby "+Dir.pwd+"/main_client.rb priorat"
      puts "Criando clientes..."
      num_machines.times do |i|
        shooter = "./shooter.exp #{user} #{machines[i]} \"#{main_client}\""
        pid = spawn({"PASS"=>pass.strip}, shooter, :out=>:out)
        Process.detach pid
        puts "Cliente criado em: #{machines[i]}"
      end
      STDOUT.flush
      print "\r"
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
  print "\r"
end
