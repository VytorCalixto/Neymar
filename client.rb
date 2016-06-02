require 'socket'

class Client
  
  attr_accessor :messages

  def initialize(server, port)
    @socket = UDPSocket.new
    @socket.connect server, port
    @messages = []
  end

  def send(msg=nil)
    if msg.nil?
      msg = @messages.first
      @messages.delete_at(0) 
    end
    @socket.send msg, 0
  end

  def send_all
    until messages.empty?
      send
    end
  end

  def messages=(msgs)
    @messages = msgs.map.with_index { |m, i| (i+1).to_s+" - "+m }
  end

  def add_messages(msgs)
    @messages.concat(msgs.map.with_index { |m, i| (@messages.size+i+1).to_s+" - "+m })
  end

end
