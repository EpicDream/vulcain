require_relative 'driver'

class Strategy
  
  def initialize &block
    @driver = Driver.new
    self.instance_eval(&block)
  end
  
  def open_url url
    @driver.get url
  end
  
  def click_on name
    element = @driver.find_element(name)
    element.click
  end
  
end