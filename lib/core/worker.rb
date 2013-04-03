# encoding: utf-8
# encoding: utf-8
require "amqp"
require_relative 'amqp_runner'
require_relative 'message'
IP_DISPATCHER = "127.0.0.1"
VULCAIN_ID = "1"

def dispatcher
  channel = AMQP::Channel.new(AMQP::Session.connect(:host => IP_DISPATCHER, :username => "guest", :password => "guest"))
  channel.on_error do |ch, channel_close|
    puts "A channel dispatcher-level exception: #{channel_close.inspect}"
  end
  exchange = channel.headers("amq.match", :durable => true)
end

class Strategy
  attr_accessor :context, :dispatcher, :session_id, :vulcain_id
  def initialize(dispatcher, session_id, vulcain_id)
    @dispatcher = dispatcher
    @context = {}
    @step = 1
    @session_id = session_id
    @vulcain_id = vulcain_id
  end
  
  def start
    step_1
  end
  
  def next_step
    send("step_#{@step}")
  end
  
  def step_1
    puts "Launch .."
    sleep(1)
    puts "Ask for answer"
    message = Message.new(:ask, {:price => 100}, session_id, vulcain_id)
    dispatcher.publish Marshal.dump(message), :headers => { :dispatcher => "vulcains"}
    @step += 1
  end
  
  def step_2
    puts "Payment"
    sleep(2)
    message = Message.new(:terminate, {}, session_id, vulcain_id)
    dispatcher.publish Marshal.dump(message), :headers => { :dispatcher => "vulcains"}
  end
  
end

AmqpRunner.start do |channel, exchange|
  dispatcher = dispatcher()
  strategy = nil
  channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :vulcain => VULCAIN_ID}).subscribe do |metadata, message|
    #TODO:voir metadata.inspect
    message = Marshal.load(message)
    puts "Vulcain received : #{message.inspect}"
    
    case message.verb
    when :response
      strategy.context[:response] = message.context[:response]
      strategy.next_step
    when :action
      strategy = Strategy.new(dispatcher, message.session_id, message.vulcain_id)
      strategy.start
    end
    
  end
  
end
