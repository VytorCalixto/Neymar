require 'socket'

class Client
  
  attr_accessor :messages

  def initialize(server, port)
    @socket = UDPSocket.new
    @socket.connect server, port
    @messages = []
  end

  def send(msg=nil)
    msg = messages.pop if msg.nil?
    p msg
    @socket.send msg, 0
  end

  def send_all
    until messages.empty?
      send
    end
  end

  def messages= msgs
    @messages = msgs.map.with_index { |m, i| (msgs.size-i).to_s+" - "+m }
  end

end