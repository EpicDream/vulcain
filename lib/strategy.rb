class Strategy
  
  attr_accessor :context
  
  def initialize &block
    @driver = Driver.new
    @block = block
  end
  
  def run
    raise unless context
    self.instance_eval(&@block)
  end
  
  def open_url url
    @driver.get url
  end
  
  def click_on name
    @driver.click_on @driver.find_element(name)
  end
  
  def fill label, args={}
    input = @driver.find_element(label)
    input.send_key args[:with]
  end
  
  def select_option label, value
    select = @driver.find_select(label)
    @driver.select_option(select, value)
  end
  
end