# encoding: utf-8
module Vulcain
  class Worker
    
    def initialize(id)
      @id = id.to_s
    end
    
    def start
      Vulcain::AmqpRunner.start do |channel, exchange|
        Vulcain.mount_exchanger
        state_machine = Vulcain::StateMachine.new(exchange)
        $stdout << "Hello you, i'm Vulcain number #{@id} and i'm started !"
        channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :vulcain => @id}).subscribe do |metadata, message|
          begin
            message = JSON.parse(message)
            state_machine.handle(message)
          rescue => e
            puts e.inspect
            puts e.backtrace.join("\n")
            page_source = state_machine.strategy.driver.driver.page_source
            File.open(File.join(File.dirname(__FILE__), 'bug.html'), 'w') { |f| f.write(page_source) }
            exchanger = Vulcain::Exchanger.new(message['session'])
            state_machine.strategy.driver.quit
            message = {'verb' => 'failure'}
            exchanger.publish message
          end
        end
      end
    end
    
  end
end
