# encoding: utf-8
module Vulcain
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