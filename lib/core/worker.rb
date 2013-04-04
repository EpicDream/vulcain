# encoding: utf-8
module Vulcain
  class Worker
    
    def initialize(id)
      @id = id.to_s
      @strategy = nil
    end
    
    #TODO:voir metadata si peut être utilisé pour identifier communication
    def start
      Vulcain::AmqpRunner.start do |channel, exchange|
        exchanger = Vulcain.exchanger
        channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :vulcain => @id}).subscribe do |metadata, message|
          begin
            message = JSON.parse(message)
            
            case message['verb']
            when 'reload'
              Vulcain.reload(message['context'])
            when 'next_step'
              puts "Vulcain received : #{message.inspect}"
              @strategy.next_step
            when 'response'
              puts "Vulcain received : #{message.inspect}"
              @strategy.context = message['context']
              @strategy.next_step(message['content'])
            when 'action'
              puts "Vulcain received : #{message.inspect}"
              @strategy = Object.const_get(message['vendor']).new(message['context']).send(message['strategy'])
              @strategy.exchanger = Vulcain::Exchanger.new(message['session'])
              @strategy.self_exchanger = Vulcain::SelfExchanger.new(message['session'], exchange)
              @strategy.run
            end
          rescue => e
            puts e.inspect
            puts e.backtrace.join("\n")
            #log
            #message : failure Vulcain::Exchanger.new(message['session']).fail
          end
        end
      end
    end
    
  end
end
