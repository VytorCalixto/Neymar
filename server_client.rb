require 'json'

class ServerClient
  attr_accessor :messages, :name, :missing, :out_of_order

  def initialize(name)
    @name = name
    @nextMessage = 1
    @missing = 0
    @out_of_order = 0
    @messages = []
  end

  def add_msg(msg)
    if msg < @nextMessage
      @out_of_order += 1
      @missing -= 1
    elsif msg > @nextMessage
      @missing += msg-@nextMessage
    end
    @messages << msg
    @nextMessage = msg+1
  end

  def status
    @name+" enviou "+@messages.size.to_s+" datagramas, teve "+@missing.to_s+" datagramas perdidos e "+@out_of_order.to_s+" datagramas desordenados."
  end

  def to_json(*a)
    {:name => @name,
    :received => @messages.size,
    :lost => @missing,
    :out_of_order => @out_of_order}.to_json(*a)
  end

end
