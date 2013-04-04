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
end