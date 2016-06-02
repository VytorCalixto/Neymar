require_relative 'client'
require_relative 'configuration'

if ARGV.length != 1
  puts "Uso correto: ruby main_server.rb <servidor>"
  abort
end

server = ARGV[0]

client = Client.new(server,Configuration::PORT)

machines_text = File.read(File.join(File.dirname(__FILE__), "machines"))
machines = machines_text.split("\n")

machines.delete_if do |m|
    result = `ping -q -c 2 #{m}`
    if $?.exitstatus != 0
        true
    end
end

p machines

commands = ['\q', '\s', '\t']

loop do
  puts "prompt=>"
  cmd = $stdin.readline()
  p cmd.strip!
  if commands.include? cmd
    if cmd == '\s'
      client.send('status')
    elsif cmd == '\t'
        puts "Realizando testes"
    else
      client.send('end')
      break
    end
  else
    p commands
  end
end
