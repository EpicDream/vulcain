module Vulcain
  class StateMachine
    
    attr_reader :robot
    
    def initialize
      @messager = Vulcain.messager
    end
    
    def initialize_robot_from message
      @messager.session = message['context']['session']
      @robot = Object.const_get(message['vendor']).new(message['context']).robot
      @robot.messager = @messager
    end
    
    def handle message
      message = JSON.parse(message)
      
      case message['verb']
      when Messager::MESSAGES_VERBS[:ping]
        @messager.admin.message(:ack_ping)
      when Messager::MESSAGES_VERBS[:reload]
        Vulcain.reload(message['code'])
        @messager.admin.message(:reloaded)
        $stdout << "Ouch ! My code has been hot reloaded. Ready !\n"
      when Messager::MESSAGES_VERBS[:answer]
        robot.context = message['context']
        robot.next_step
      when Messager::MESSAGES_VERBS[:next_step]
        robot.next_step
      when Messager::MESSAGES_VERBS[:run]
        initialize_robot_from(message)
        robot.run
      when Messager::MESSAGES_VERBS[:crawl]
        initialize_robot_from(message)
        robot.crawl
      end
      
    rescue => e
      rescuer(e)
    end
    
    private
    
    def rescuer e
      @messager.dispatcher.message(:failure, { status:'exception'})
      @messager.admin.message(:failure)
      @messager.logging.message(:screenshot, @robot.driver.screenshot)
      @messager.logging.message(:page_source, @robot.driver.page_source)
      @messager.logging.message(:error_message, e.inspect)
      @messager.logging.message(:stack_trace, e.backtrace.join("\n"))
      @robot.driver.quit
    end
    
  end
end