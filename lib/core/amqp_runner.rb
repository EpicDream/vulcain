# encoding: utf-8
module Vulcain
  class AmqpRunner
    
    def self.start
      AMQP.start(host:Vulcain::HOST, username:Vulcain::USER, password:Vulcain::PASSWORD) do |connection|
        channel = AMQP::Channel.new(connection)
        channel.on_error do |channel, channel_close| 
          raise "Can't open channel to local vulcain MQ server on #{HOST}"
        end
        exchange = channel.headers("amq.match", :durable => true)

        Signal.trap "INT" do
          connection.close {
            EventMachine.stop { abort }
            $selenium_headless_runner.destroy
          }
        end
      
        yield channel, exchange
      
      end
    end
  
  end
end



