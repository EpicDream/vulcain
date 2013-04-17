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
        
        channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :queue => "vulcain-#{@id}").subscribe do |metadata, message|
          begin
            message = JSON.parse(message)
            state_machine.handle(message)
          rescue => e
            strategy = state_machine.strategy
            strategy.logging_exchanger.publish({screenshot:strategy.driver.screenshot_as(:base64)})
            strategy.logging_exchanger.publish({page_source:strategy.driver.driver.page_source})
            strategy.logging_exchanger.publish({error_message:e.inspect})
            strategy.logging_exchanger.publish({error_message:e.backtrace.join("\n")})
            strategy.driver.quit
          end
        end
      end
    end
    
  end
end
