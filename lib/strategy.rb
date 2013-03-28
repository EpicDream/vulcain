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
  
  def click_on_radio value, choices
    choices.each do |choice, xpath|
      click_on(xpath) and break if choice == value
    end
  end
  
  def click_on_all xpaths
    start = Time.now
    begin
      element = xpaths.inject(nil) do |element, xpath|
        element = @driver.find_element(xpath, nowait:true)
        break element if element
        element
      end
      @driver.click_on(element) if element
      continue = yield element
      raise if continue && Time.now - start > 30
    end while continue
  end
  
  def fill xpath, args={}
    input = @driver.find_element(xpath)
    input.clear
    input.send_key args[:with]
  end
  
  def select_option xpath, value
    select = @driver.find_element(xpath)
    @driver.select_option(select, value)
  end
  
  def exists? xpath
    !!@driver.find_element(xpath, nowait:true)
  end
  
  def wait_for xpaths
    xpaths.each { |xpath| @driver.find_element(xpath) }
  end
  
  def alert?
    @driver.alert?
  end
  
  def accept_alert
    @driver.accept_alert
  end
  
end