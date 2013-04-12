module Vulcain
  class StateMachine
    
    def initialize exchange
      @exchange = exchange
    end
    
    def handle message
      case message['verb']
      when 'reload'
        Vulcain.reload(message['context'])
      when 'answer'
        @strategy.context = message['context']
        @strategy.next_step
      when 'next_step'
        @strategy.next_step
      when 'run'
        @strategy = Object.const_get(message['vendor']).new(message['context']).strategy
        @strategy.exchanger = Vulcain::Exchanger.new(message['context']['session'])
        @strategy.self_exchanger = Vulcain::SelfExchanger.new(message['context']['session'], @exchange)
        @strategy.run
      end
    end
    
  end
end