require "minitest/autorun"
require File.join(File.dirname(__FILE__), '../lib/core/vulcain.rb')
require "mocha"

describe Vulcain::StateMachine do
  EXCHANGERS = [Vulcain::DispatcherExchanger, Vulcain::SelfExchanger, Vulcain::LoggingExchanger, Vulcain::AdminExchanger]
  VULCAIN_ID = "1"
  
  before do
    stubs_exchangers
    stubs_messager
    @robot = stub
    
    @state_machine = Vulcain::StateMachine.new
    @state_machine.stubs(:robot).returns(@robot)
  end
  
  describe 'respond to messages' do
    it 'should respond to ping verb' do
      expect_publish_with({status: 'ack_ping'})

      @state_machine.handle({verb:'ping'}.to_json)
    end
    
    it 'should respond to reload verb with call to Vulcain module to reload code' do
      expect_publish_with({status: 'reloaded'})
      Vulcain.expects(:reload).with('class Foo;end')

      @state_machine.handle({verb:'reload', code:'class Foo;end'}.to_json)
    end
    
    it 'should call robot#next_step on anwser verb and pass context to robot' do
      @robot.expects(:context=).with({"answer" => "answer"})
      @robot.expects(:next_step)
      
      @state_machine.handle({verb:'answer', context:{answer:"answer"}}.to_json)
    end
    
    it 'should initialize robot and call robot#run on run verb' do
      @state_machine.expects(:initialize_robot_from)
      @robot.expects(:run)

      @state_machine.handle({verb:'run', context:{}}.to_json)
    end
    
    it 'should initialize robot and call robot#crawl on crawl verb' do
      @state_machine.expects(:initialize_robot_from)
      @robot.expects(:crawl)

      @state_machine.handle({verb:'crawl', context:{}}.to_json)
    end
    
  end
  
  def stubs_exchangers
    @exchange = stub
    expect_publish_with({:status => 'started'})
    EXCHANGERS.each {|exchanger| exchanger.stubs(:new).returns(@exchange)}
  end
  
  def stubs_messager
    @messager = Vulcain::Messager.new(VULCAIN_ID, @exchange)
    Vulcain.stubs(:messager).returns(@messager)
  end
  
  def expect_publish_with message
    session = {:vulcain_id => VULCAIN_ID}
    @exchange.expects(:publish).with(message, session)
  end
end