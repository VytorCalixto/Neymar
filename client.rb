require 'socket'

class Client
  
  attr_accessor :messages

  def initialize(server, port)
    @socket = UDPSocket.new
    @socket.connect server, port
  end

  def send
    msg = messages.pop
    p msg
    @socket.send msg, 0
  end

  def send_all
    until messages.empty?
      send
    end
  end

end