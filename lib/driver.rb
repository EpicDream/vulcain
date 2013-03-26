require "selenium-webdriver"

class Driver
  USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"

  attr_accessor :driver, :wait
  
  def initialize
    @driver = Selenium::WebDriver.for :chrome, :switches => ["--user-agent=#{USER_AGENT}"]
    @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
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
      if option.attribute("value") == value
        option.click
        break
      end
    end
  end
  
  def click_on element
    wait.until do 
      begin
        element.click
      rescue => e
        sleep(0.1) and retry
      end  
    end
  end

  
  def find_select label
    wait.until do
      begin
        element = driver.find_elements(:xpath => "//*[text()='#{label}']").first
        unless element
          element = driver.find_elements(:xpath => "//*[@name='#{label}']").first
        end
        if element && element.tag_name != "select"
          element = driver.find_elements(:xpath => "//*[text()='#{label}']/following-sibling::select").first
        end
        element
      rescue => e
        puts e.inspect
        sleep(0.1) and retry
      end
    end
    
  end
  
  def find_element label
    wait.until do
      begin
        link = driver.find_elements(:xpath => "//*[text()='#{label}']").first
        unless link
          link = driver.find_elements(:xpath => "//*[@value='#{label}']").first
        end
        unless link
          link = driver.find_elements(:xpath => "//*[@name='#{label}']").first
        end
        if link && link.tag_name == "label"
          link = driver.find_elements(:xpath => "//*[text()='#{label}']/following-sibling::input").first
          unless link
            link = driver.find_elements(:xpath => "//*[text()='#{label}']/input").first
          end
        end
        link
      rescue => e
        puts e.inspect
        sleep(0.1) and retry
      end
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
      end
    end
  end
  
end
