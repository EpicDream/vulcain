module Vulcain
  class StateMachine
    
    attr_reader :strategy, :session
    
    def initialize exchange, id
      @exchange = exchange
      @id = id
    end
    
    def initialize_strategy_from message
      @session = message['context']['session']
      @strategy = Object.const_get(message['vendor']).new(message['context']).strategy
      @strategy.exchanger = Vulcain::DispatcherExchanger.new(session)
      @strategy.self_exchanger = Vulcain::SelfExchanger.new(session, @exchange)
      @strategy.logging_exchanger = Vulcain::LoggingExchanger.new(session)
    end
    
    def handle message
      case message['verb']
      when MESSAGES_VERBS[:reload]
        Vulcain.reload(message['code'])
        Vulcain::AdminExchanger.new({vulcain_id:@id}).publish({status:MESSAGES_STATUSES[:reloaded]})
        $stdout << "Ouch ! My code has been hot reloaded. Ready !\n"
      when 'answer'
        @strategy.context = message['context']
        @strategy.next_step
      when 'next_step'
        @strategy.next_step
      when 'run'
        initialize_strategy_from(message)
        @strategy.run
      end
    end
    
  end
end