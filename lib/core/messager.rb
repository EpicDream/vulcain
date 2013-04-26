module Vulcain
  class Messager
    
    attr_accessor :session
    
    def initialize(vulcain_id, exchanger)
      @vulcain_id = vulcain_id
      @dispatcher_exchanger = DispatcherExchanger.new
      @self_exchanger = SelfExchanger.new(vulcain_id, exchanger)
      @logging_exchanger = LoggingExchanger.new
      @admin_exchanger = AdminExchanger.new
    end
    
    def admin
      @exchanger = @admin_exchanger
      @message = lambda { |msg, _| { status:ADMIN_MESSAGES_STATUSES[msg] } }
      self 
    end
    
    def dispatcher
      @exchanger = @dispatcher_exchanger
      @message = lambda { |msg, content| {verb:MESSAGES_VERBS[msg], content:content} }
      self 
    end
    
    def logging
      @exchanger = @logging_exchanger
      @message = lambda { |msg, content| {verb:msg.to_s, content:content} }
      self 
    end
    
    def vulcain
      @exchanger = @self_exchanger
      @message = lambda { |msg, _| {verb:msg.to_s} }
      self 
    end
    
    def message msg, content=nil
      @exchanger.publish(@message.(msg, content), session)
    end
    
  end
end