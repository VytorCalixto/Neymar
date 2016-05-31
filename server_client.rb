class ServerClient
  attr_accessor :messages, :name, :nextMessage, :ordered, :missing

  def initialize
    @nextMessage = 0
    @ordered = true
  end

  def addMsg msg
    if msg != nextMessage
      @ordered = false 
      @missing << nextMessage
    end
    @missing.del(msg) if @missing.include? msg
    @messages.push(msg)
    @nextMessage++
  end

end