# encoding: utf-8
module Vulcain
  
  class Exchanger
    def initialize session, exchanger, queue
      @session = session
      @exchanger = exchanger
      @queue = queue
    end
    
    def publish message, session=@session
      message['session'] = session
      @exchanger.publish message.to_json, :headers => {queue:@queue}
    end
  end
  
  class DispatcherExchanger < Exchanger

    def initialize session
      super(session, Vulcain.exchanger, DISPATCHER_VULCAINS_QUEUE)
    end

  end
  
  class LoggingExchanger

    def initialize session
      super(session, Vulcain.exchanger, LOGGING_QUEUE)
    end

  end
  
  class SelfExchanger

    def initialize session, exchanger
      super(session, exchanger, "vulcain#{session['vulcain_id']}")
    end

  end
end