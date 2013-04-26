# encoding: utf-8
module Vulcain
  class Worker
    
    def initialize(id)
      @id = id.to_s
    end
    
    def start
      Vulcain::AmqpRunner.start(@id) do |channel, exchange|
        @messager = Messager.new(@id, exchange)
        Vulcain.messager = @messager
        @state_machine = Vulcain::StateMachine.new
        $stdout << "I'm Vulcain number #{@id} and i'm started !\n"
        @messager.session = { vulcain_id:@id }
        @messager.admin.message(:started)
        # Vulcain::AdminExchanger.new({vulcain_id:@id}).publish({:status => ADMIN_MESSAGES_STATUSES[:started]})
        
        channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :queue => VULCAIN_QUEUE.(@id)}).subscribe do |metadata, message|
          begin
            message = JSON.parse(message)
            @state_machine.handle(message)
          rescue => e
            session = @state_machine.session if @state_machine
            if session
              @messager.session = session
              @messager.dispatcher.message(:failure, { status:'exception'})
              #message = {'verb' => MESSAGES_VERBS[:failure], 'content' => {status:'exception'}}
              # DispatcherExchanger.new(session).publish(message)
            end
            #exchanger = LoggingExchanger.new(session)
            if @state_machine && @state_machine.robot
              driver = @state_machine.robot.driver
              @message.logging.message(:screenshot, driver.screenshot)
              @message.logging.message(:page_source, driver.page_source)
              # exchanger.publish({ screenshot:driver.screenshot })
              # exchanger.publish({ page_source:driver.page_source })
              driver.quit
            end
            @messager.admin.message(:failure)
            @message.logging.message(:error_message, e.inspect)
            @message.logging.message(:stack_trace, e.backtrace.join("\n"))
            # AdminExchanger.new({vulcain_id:@id}).publish({status:ADMIN_MESSAGES_STATUSES[:failure]})
            # exchanger.publish({ error_message:e.inspect })
            # exchanger.publish({ stack_trace:e.backtrace.join("\n") })
          end
        end
      end
    end
    
  end
end
