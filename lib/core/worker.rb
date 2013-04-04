# encoding: utf-8
module Vulcain
  class Worker
    
    def initialize(id)
      @id = id.to_s
      @strategy = nil
    end
    
    def start
      Vulcain::AmqpRunner.start do |channel, exchange|
        dispatcher = Vulcain.dispatcher
        channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :vulcain => @id}).subscribe do |metadata, message|
          #TODO:voir metadata.inspect si peut être utilisé pour identifier communication
          message = JSON.parse(message)
          puts "Vulcain received : #{message.inspect}"

          case message['verb']
          when 'reload'
            Vulcain.load(message['context'])
          when 'response'
            @strategy.next_step#(response)
            
            # SI TERMINE ==>
            
            # message = {'verb' => 'close'}
            # dispatcher.publish message.to_json, :headers => { :queue => DISPATCHER_VULCAINS_QUEUE}
          when 'action'
            @strategy = Object.const_get(message['vendor']).new(message['context']).send(message['strategy'])
            @strategy.run
            # message = {'verb' => 'ask', 'content' => 'Validez vous ?'}
            # dispatcher.publish message.to_json, :headers => { :queue => DISPATCHER_VULCAINS_QUEUE}
          end
        end
      end
    end
    
  end
end
