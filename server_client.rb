class ServerClient
  attr_accessor :messages, :name, :nextMessage, :sorted, :missing

  def initialize
    @nextMessage = 0
    @sorted = true
    @missing = []
  end

  def addMsg msg
    @sorted = false if msg != nextMessage
    @missing.del(msg) if @missing.include? msg
    @messages << msg
    @nextMessage++
  end

  def missing
    return [] unless((@messages.size-@messages.first) < @messages.last)
    n = (@messages.first..@messages.size).to_a
    n-@messages
  end

end