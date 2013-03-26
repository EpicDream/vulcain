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
  
  def click_on identifier
    if identifier.is_a?(Hash) && xpath = identifier[:xpath]
      @driver.click_on(@driver.find_element_by_xpath xpath)
    else
      @driver.click_on @driver.find_element(identifier)
    end
  end
  
  def click_on_image url
    image = @driver.find_element_by_xpath("//img[@src='#{url}']")
    @driver.click_on(image)
  end
  
  def click_on_all xpath, &block
    begin
      element = @driver.find_element_by_xpath(xpath, nowait:true).first
      @driver.click_on(element) if element
      block.call 
    end while element
  end
  
  def fill label, args={}
    input = @driver.find_element(label)
    input.send_key args[:with]
  end
  
  def select_option label, value
    select = @driver.find_select(label)
    @driver.select_option(select, value)
  end
  
  def wait_for labels
    @driver.wait_for(labels)
  end
  
  def assert_element label
    @driver.wait_for([label])
  end
  
end