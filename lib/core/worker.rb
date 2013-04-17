# encoding: utf-8
module Vulcain
  class Worker
    
    def initialize(id)
      @id = id.to_s
    end
    
    def start
      Vulcain::AmqpRunner.start do |channel, exchange|
        Vulcain.mount_exchanger
        state_machine = Vulcain::StateMachine.new(exchange)
        $stdout << "Hello you, i'm Vulcain number #{@id} and i'm started !\n"
        
        channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :queue => "vulcain-#{@id}"}).subscribe do |metadata, message|
          begin
            message = JSON.parse(message)
            state_machine.handle(message)
          rescue => e
            raise unless state_machine
            exchanger = state_machine.strategy.logging_exchanger
            driver = state_machine.strategy.driver
            exchanger.publish({screenshot:driver.screenshot})
            exchanger.publish({page_source:driver.page_source})
            exchanger.publish({error_message:e.inspect})
            exchanger.publish({error_message:e.backtrace.join("\n")})
            driver.quit
          end
        end
      end
    end
    
  end
end
