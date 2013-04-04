# encoding: utf-8
module Vulcain
  class Exchanger

    def initialize session
      @session = session
      @exchanger = Vulcain.exchanger
    end

    def publish message
      message['session'] = @session
      @exchanger.publish message.to_json, :headers => {queue:DISPATCHER_VULCAINS_QUEUE}
    end

  end
  
  class SelfExchanger

    def initialize session, exchanger
      @session = session
      @exchanger = exchanger
    end

    def publish message
      message['session'] = @session
      @exchanger.publish message.to_json, :headers => { :vulcain => @session['vulcain_id']}
    end

  end
end