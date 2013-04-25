module Vulcain
  class StateMachine
    
    attr_reader :robot, :session
    
    def initialize exchange, id
      @exchange = exchange
      @id = id
    end
    
    def initialize_robot_from message
      @session = message['context']['session']
      @robot = Object.const_get(message['vendor']).new(message['context']).robot
      @robot.exchanger = Vulcain::DispatcherExchanger.new(session)
      @robot.self_exchanger = Vulcain::SelfExchanger.new(session, @exchange)
      @robot.logging_exchanger = Vulcain::LoggingExchanger.new(session)
    end
    
    def handle message
      case message['verb']
      when MESSAGES_VERBS[:ping]
        Vulcain::AdminExchanger.new({vulcain_id:@id}).publish({status:ADMIN_MESSAGES_STATUSES[:ack_ping]})
      when MESSAGES_VERBS[:reload]
        Vulcain.reload(message['code'])
        Vulcain::AdminExchanger.new({vulcain_id:@id}).publish({status:ADMIN_MESSAGES_STATUSES[:reloaded]})
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