require "selenium-webdriver"

class Driver
  USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
  TIMEOUT = 20
  
  attr_accessor :driver, :wait
  
  def initialize
    @driver = Selenium::WebDriver.for :chrome, :switches => ["--user-agent=#{USER_AGENT}"]
    @wait = Selenium::WebDriver::Wait.new(:timeout => TIMEOUT)
  end
  
  def quit
    @driver.quit
  end
  
  def get url
    @driver.get url
  end

  def select_option select, value
    options = select.find_elements(:tag_name, "option")
    options.each do |option|
      next unless option.attribute("value") == value
      option.click
      break
    end
  end
  
  def click_on element
    waiting { element.click }
  end

  def find_select label
    waiting do
      element = find_successive(label)
      element = find_successive_sibling(label, "select") if element && element.tag_name != "select"
      element
    end
  end
  
  def find_element label
    waiting do
      element = find_successive(label)
      if element && element.tag_name == "label"
        element = find_successive_sibling(label, "input")
        element = driver.find_elements(:xpath => "//*[text()='#{label}']/input").first unless element
      end
      element
    end
  end
  
  def find_element_by_xpath xpath, options={}
    if options[:nowait]
      driver.find_elements(:xpath => xpath)
    else
      wait.until { driver.find_element(:xpath => xpath) }
    end
  end
  
  def find_elements_by_xpath xpath
    wait.until { driver.find_element(:xpath => xpath) }
  end
  
  def wait_for labels
    wait.until do
      labels.inject(nil) do |element, label| 
        element = driver.find_elements(:xpath => "//*[text()='#{label}']").first
        break element if element
        element
      end
    end
  end
  
  private
  
  def find_successive label
    ["text()", "@name", "@value"].inject(nil) do |element, attribute|
      element = driver.find_elements(:xpath => "//*[#{attribute}='#{label}']").first
      break element if element
      element
    end
  end
  
  def find_successive_sibling label, tag
    ["text()", "@name", "@value"].inject(nil) do |element, attribute|
      element = driver.find_elements(:xpath => "//*[#{attribute}='#{label}']/following-sibling::#{tag}").first
      break element if element
      element
    end
  end
  
  def waiting
    wait.until do 
      begin
        yield
      rescue => e
        puts e.inspect
        sleep(0.1) and retry
      end  
    end
  end
  
end
