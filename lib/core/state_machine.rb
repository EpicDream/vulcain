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
      case message['verb']
      when Messager::MESSAGES_VERBS[:ping]
        @messager.admin.message(:ack_ping)
      when Messager::MESSAGES_VERBS[:reload]
        Vulcain.reload(message['code'])
        @messager.admin.message(:reloaded)
        $stdout << "Ouch ! My code has been hot reloaded. Ready !\n"
      when 'answer'
        @robot.context = message['context']
        @robot.next_step
      when 'next_step'
        @robot.next_step
      when 'run'
        initialize_robot_from(message)
        @robot.run
      end
    end
    
  end
end