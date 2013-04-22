# encoding: utf-8
module Vulcain
  class Worker
    
    def initialize(id)
      @id = id.to_s
    end
    
    def start
      Vulcain::AmqpRunner.start do |channel, exchange|
        state_machine = Vulcain::StateMachine.new(exchange, @id)
        $stdout << "I'm Vulcain number #{@id} and i'm started !\n"
        Vulcain::AdminExchanger.new({vulcain_id:@id}).publish({:status => MESSAGES_STATUSES[:started]})
        
        channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :queue => VULCAIN_QUEUE.(@id)}).subscribe do |metadata, message|
          begin
            message = JSON.parse(message)
            state_machine.handle(message)
          rescue => e
            #state_machine.handle_failure
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
