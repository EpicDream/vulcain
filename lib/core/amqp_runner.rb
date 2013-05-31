# encoding: utf-8
module Vulcain
  class AmqpRunner
    
    def self.start vulcain_id
      AMQP.start(host:CONFIG['host'], username:CONFIG['user'], password:CONFIG['password']) do |connection|
        channel = AMQP::Channel.new(connection)
        channel.on_error do |channel, channel_close| 
          raise "Can't open channel to local vulcain MQ server on #{CONFIG['host']}"
        end
        exchange = channel.headers("amqp.headers")
        
        EM.add_periodic_timer(PING_INTERVAL) do
          Vulcain.messager.admin.message(:ping)
        end
        
        Signal.trap "INT" do
          Vulcain.messager.admin.message(:aborted)
          connection.close { EventMachine.stop { abort }}
        end
      
        yield channel, exchange
      
      end
    end
  
  end
end



