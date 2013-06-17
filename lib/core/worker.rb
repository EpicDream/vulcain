# encoding: utf-8
module Vulcain
  class Worker
    
    def initialize(id)
      @id = id.to_s
    end
    
    def start
      Vulcain::AmqpRunner.start(@id) do |channel, exchange|
        Vulcain.messager = Messager.new(@id, exchange)
        state_machine = Vulcain::StateMachine.new
        
        channel.queue.bind(exchange, :arguments => binding_arguments).subscribe do |metadata, message|
          state_machine.handle(message)
        end
        
      end
    end
    
    def binding_arguments
      { 'x-match' => 'all', :queue => VULCAIN_QUEUE.(@id)}
    end
    
  end
end
