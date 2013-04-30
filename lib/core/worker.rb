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
        
        channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :queue => VULCAIN_QUEUE.(@id)}).subscribe do |metadata, message|
          begin
            message = JSON.parse(message)
            @state_machine.handle(message)
          rescue => e
            @messager.dispatcher.message(:failure, { status:'exception'})
            if @state_machine && @state_machine.robot
              driver = @state_machine.robot.driver
              @messager.logging.message(:screenshot, driver.screenshot)
              @messager.logging.message(:page_source, driver.page_source)
              driver.quit
            end
            @messager.admin.message(:failure)
            @messager.logging.message(:error_message, e.inspect)
            @messager.logging.message(:stack_trace, e.backtrace.join("\n"))
          end
        end
      end
    end
    
  end
end
