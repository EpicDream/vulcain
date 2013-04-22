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
        
        channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :queue => VULCAIN_QUEUE.(@id)}).subscribe do |metadata, message|
          begin
            message = JSON.parse(message)
            state_machine.handle(message)
          rescue => e
            session = message['context']['session'] if message
            exchanger = LoggingExchanger.new(session)
            if state_machine && state_machine.strategy
              driver = state_machine.strategy.driver
              exchanger.publish({ screenshot:driver.screenshot })
              exchanger.publish({ page_source:driver.page_source })
              driver.quit
            end
            exchanger.publish({ error_message:e.inspect })
            exchanger.publish({ stack_trace:e.backtrace.join("\n") })
          end
        end
      end
    end
    
  end
end
