# encoding: utf-8
module Vulcain
  
  class Exchanger
    @@exchanger = nil
    
    def initialize session, queue, exchanger=dispatcher_exchanger
      @session = session
      @exchanger = exchanger 
      @queue = queue
    end
    
    def publish message, session=@session
      message['session'] = session
      @exchanger.publish message.to_json, :headers => {queue:@queue}
    end
    
    def dispatcher_exchanger
      return @@exchanger if @@exchanger
      connection = AMQP::Session.connect(configuration)
      channel = AMQP::Channel.new(connection)
      channel.on_error(&channel_error_handler)
      @@exchanger = channel.headers("amq.match", :durable => true)
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

    def initialize session
      super(session, DISPATCHER_VULCAINS_QUEUE)
    end

  end
  
  class AdminExchanger < Exchanger

    def initialize session
      super(session, ADMIN_QUEUE)
    end

  end
  
  
  class LoggingExchanger < Exchanger

    def initialize session
      super(session, LOGGING_QUEUE)
    end

  end
  
  class SelfExchanger < Exchanger

    def initialize session, exchanger
      super(session, VULCAIN_QUEUE.(session['vulcain_id']), exchanger)
    end

  end
end