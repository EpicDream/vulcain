require "selenium-webdriver"

class Driver
  USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"

  attr_accessor :driver, :wait
  
  def initialize
    @driver = Selenium::WebDriver.for :chrome, :switches => ["--user-agent=#{USER_AGENT}"]
    @wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  end
  
  def get url
    @driver.get url
  end

  def select_option xpath, value
    options = get_element(xpath).find_elements(:tag_name, "option")
    options.each do |option|
      if option.attribute("value") == value
        option.click
        break
      end
    end
  end

  def fill xpath, args={}
    element = get_element(xpath)
    element.send_key args[:with]
  end

  def click_on xpath
    wait.until do 
      begin
        element = driver.find_element(:xpath => xpath)
        element.click
      rescue => e
        sleep(0.1) and retry
      end  
    end
  end

  def get_elements xpath
    wait.until { driver.find_elements(:xpath => xpath).any? }
    driver.find_elements(:xpath => xpath)
  end
  
  def find_element displayed_text
    wait.until do
      links = driver.find_elements(:xpath => ".//a")
      links.select { |link| link.text.downcase == displayed_text.downcase }.first
    end
    
  end

  def get_element_by_match xpath, block
    element = nil
    wait.until do 
      begin
      elements = get_elements(xpath)
      links = elements.select(&block)
      element = links.first
      links.any?
      rescue
        sleep(0.1) and retry
      end  
    end
    element
  end

  def get_element xpath
    wait.until { driver.find_element(:xpath => xpath) }
  end

end
