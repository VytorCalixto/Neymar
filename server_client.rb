class ServerClient
  attr_accessor :messages, :name, :nextMessage, :sorted

  def initialize(name)
    @name = name
    @nextMessage = 1
    @sorted = true
    @messages = []
  end

  def addMsg(msg)
    @sorted = false if msg != nextMessage
    @messages << msg
    @nextMessage+=1
  end

  def missing
    return [] unless((@messages.size-@messages.first) < @messages.last)
    n = (@messages.first..@messages.size).to_a
    n-@messages
  end

  def status
    s = @name + " teve " + missing.size.to_s + " datagramas perdidos e"
    s += " não " if @sorted
    s += " teve datagramas desordenados."
    return s
  end

end
