# encoding: utf-8
module Vulcain
  
  class Exchanger
    @@exchanger = nil
    
    def initialize queue, exchanger=dispatcher_exchanger
      @exchanger = exchanger 
      @queue = queue
    end
    
    def publish message, session
      message['session'] = session
      @exchanger.publish message.to_json, :headers => { queue:@queue }
    end
    
    def dispatcher_exchanger
      return @@exchanger if @@exchanger
      connection = AMQP::Session.connect(configuration)
      channel = AMQP::Channel.new(connection)
      channel.on_error(&channel_error_handler)
      @@exchanger = channel.headers("amqp.headers")
    end
    
    def configuration
      config = CONFIG['dispatcher']
      { host:config['host'], username:config['user'], password:config['password'] }
    end
    
    def channel_error_handler
      Proc.new do |channel, channel_close|
        raise "Can't open channel to dispatcher MQ on #{CONFIG['dispatcher']['host']}"
      end
    end
    
  end
  
  class DispatcherExchanger < Exchanger

    def initialize
      super DISPATCHER_VULCAINS_QUEUE
    end

  end
  
  class AdminExchanger < Exchanger

    def initialize
      super ADMIN_QUEUE
    end

  end
  
  class LoggingExchanger < Exchanger

    def initialize
      super LOGGING_QUEUE
    end

  end
  
  class SelfExchanger < Exchanger

    def initialize vulcain_id, exchanger
      super VULCAIN_QUEUE.(vulcain_id), exchanger
    end

  end
end