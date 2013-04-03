# encoding: utf-8
module Vulcain
  class Worker
    
    def initialize(id)
      @id = id.to_s
    end
    
    def start
      Vulcain::AmqpRunner.start do |channel, exchange|
        dispatcher = Vulcain.dispatcher
        channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :vulcain => @id}).subscribe do |metadata, message|
          #TODO:voir metadata.inspect
          message = JSON.parse(message)
          puts "Vulcain received : #{message.inspect}"

          case message['verb']
          when 'response'
            puts "Vulcain terminate .."
            sleep(1)
            message = {'verb' => 'close'}
            dispatcher.publish message.to_json, :headers => { :queue => DISPATCHER_VULCAINS_QUEUE}
          when 'action'
            puts "Vulcain perform action ..."
            sleep(2)
            message = {'verb' => 'ask', 'content' => 'Validez vous ?'}
            dispatcher.publish message.to_json, :headers => { :queue => DISPATCHER_VULCAINS_QUEUE}
          end
        end
      end
    end
    
  end
end
