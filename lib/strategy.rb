class Strategy
  
  attr_accessor :context
  
  def initialize context, driver=nil, &block
    @driver = driver || Driver.new
    @block = block
    @context = context
  end
  
  def run
    raise unless context
    self.instance_eval(&@block)
  end
  
  def open_url url
    @driver.get url
  end
  
  def click_on xpath
    @driver.click_on @driver.find_element(xpath)
  end
  
  def click_on_if_exists xpath
    element = @driver.find_element(xpath, nowait:true)
    @driver.click_on(element) if element
  end
  
  def click_on_all xpath
    begin
      element = @driver.find_element(xpath, nowait:true)
      @driver.click_on(element) if element
    end while element
  end
  
  def fill xpath, args={}
    input = @driver.find_element(xpath)
    input.send_key args[:with]
  end
  
  def select_option xpath, value
    select = @driver.find_element(xpath)
    @driver.select_option(select, value)
  end
  
  def assert_element xpath
    @driver.find_element(xpath)
  end
  
end