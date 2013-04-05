if defined?(Driver)
  Object.send(:remove_const, :Driver)
end

if defined?(Strategy)
  Object.send(:remove_const, :Strategy)
end

if defined?(RueDuCommerce)
  Object.send(:remove_const, :RueDuCommerce)
end

require "selenium-webdriver"
require "headless"

$selenium_headless_runner = Headless.new
$selenium_headless_runner.start

class Driver
  USER_AGENT = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.60 Safari/537.17"
  TIMEOUT = 20
  
  attr_accessor :driver, :wait
  
  def initialize options={}
    @driver = Selenium::WebDriver.for :chrome, :switches => ["--user-agent=#{options[:user_agent] || USER_AGENT}"]
    @wait = Selenium::WebDriver::Wait.new(:timeout => TIMEOUT)
  end
  
  def quit
    @driver.quit
  end
  
  def get url
    @driver.get url
  end
  
  def alert?
    @driver.alert?
  end
  
  def accept_alert
    @driver.switch_to.alert.accept
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
  
  def find_element xpath, options={}
    return driver.find_elements(:xpath => xpath).first if options[:nowait]
    waiting { driver.find_elements(:xpath => xpath).first }
  end
  
  private
  
  def waiting
    wait.until do 
      begin
        yield
      rescue => e
        sleep(0.1) and retry
      end  
    end
  end
  
end

class Strategy
  LOGGED_MESSAGE = 'logged'
  EMPTIED_CART_MESSAGE = 'empty_cart'
  PRICE_KEY = 'price'
  SHIPPING_PRICE_KEY = 'shipping_price'
  TOTAL_TTC_KEY = 'total_ttc'
  RESPONSE_OK = 'ok'
  
  attr_accessor :context, :exchanger, :self_exchanger
  
  def initialize context, &block
    @driver = Driver.new
    @block = block
    @context = context
    @step = 0
    @steps = []
  end
  
  def start
    @steps[@step].call
  end
  
  def next_step response=nil
    @steps[@step += 1].call(response)
  end
  
  def step n, &block
    @steps[n - 1] = block
  end
  
  def run
    self.instance_eval(&@block)
    start
  end
  
  def confirm message
    message = {'verb' => 'confirm', 'content' => message}.merge!({'session' => context['session']})
    exchanger.publish message
  end
  
  def terminate
    message = {'verb' => 'terminate'}.merge!({'session' => context['session']})
    exchanger.publish message
  end
  
  def message message
    message = {'verb' => 'message', 'content' => message}.merge!({'session' => context['session']})
    exchanger.publish message
    self_exchanger.publish({'verb' => 'next_step'})
  end
  
  def get_text xpath
    @driver.find_element(xpath).text
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
class RueDuCommerce
  URL = 'http://www.rueducommerce.fr/home/index.htm'
  SKIP = '//*[@id="ox-is-skip"]/img'
  MY_ACCOUNT = '//*[@id="linkJsAccount"]/div/div[2]/span[1]'
  EMAIL_CREATE = '//*[@id="loginNewAccEmail"]'
  EMAIL_LOGIN = '//*[@id="loginAutEmail"]'
  PASSWORD_LOGIN = '//*[@id="loginAutPassword"]'
  LOGIN_BUTTON = '//*[@id="loginAutSubmit"]'
  CREATE_ACCOUNT = '//*[@id="loginNewAccSubmit"]'
  PASSWORD_CREATE = '//*[@id="AUT_password"]'
  PASSWORD_CONFIRM = '//*[@id="content"]/form/div/div[2]/div/div[4]/input'
  BIRTH_DAY = '//*[@id="content"]/form/div/div[2]/div/div[7]/select[1]'
  BIRTH_MONTH = '//*[@id="content"]/form/div/div[2]/div/div[7]/select[2]'
  BIRTH_YEAR = '//*[@id="content"]/form/div/div[2]/div/div[7]/select[3]'
  PHONE = '//*[@id="content"]/form/div/div[3]/div/div[1]/input'
  CIVILITY_M = '//*[@id="content"]/form/div/div[3]/div/div[3]/input[1]'
  CIVILITY_MME = '//*[@id="content"]/form/div/div[3]/div/div[3]/input[2]'
  CIVILITY_MLLE = '//*[@id="content"]/form/div/div[3]/div/div[3]/input[3]'
  FIRSTNAME = '//*[@id="content"]/form/div/div[3]/div/div[4]/input'
  LASTNAME = '//*[@id="content"]/form/div/div[3]/div/div[5]/input'
  ADDRESS = '//*[@id="content"]/form/div/div[3]/div/div[6]/input'
  ADDRESS_SUPP = '//*[@id="content"]/form/div/div[3]/div/div[7]/input'
  POSTALCODE = '//*[@id="content"]/form/div/div[3]/div/div[12]/input'
  CITY = '//*[@id="content"]/form/div/div[3]/div/div[13]/input'
  VALIDATE_ACCOUNT_CREATION = '//*[@id="content"]/form/div/input'
  ADD_TO_CART = '//*[@id="productPurchaseButton"]'
  ACCESS_CART = '//*[@id="shopr"]/div[5]/a[2]/img'
  MY_CART = '//*[@id="BasketLink"]/div[2]/span[1]'
  REMOVE_PRODUCT = '//*[@id="content"]/form[3]/div[3]/div[2]/div[1]'
  FINALIZE_ORDER = '//*[@id="FormCaddie"]/input[1]'
  EMPTY_CART_MESSAGE = '//*[@id="content"]/div[5]'
  COMPANY = '//*[@id="content"]/form/div/div[3]/div/div[8]/input'
  SHIP_ACCESS_CODE = '//*[@id="content"]/form/div/div[3]/div/div[10]/input'
  COUNTRY_SELECT = '//*[@id="content"]/form/div/div[3]/div/div[14]/select'
  VALIDATE_SHIP_ADDRESS = '//*[@id="content"]/div[4]/div[2]/div/form/input[1]'
  VALIDATE_SHIPPING = '//*[@id="btnValidContinue"]'
  VALIDATE_CARD_PAYMENT = '//*[@id="inpMop1"]'
  VALIDATE_VISA_CARD = '//*[@id="content"]/div/form/div[1]/input[2]'
  CREDIT_CARD_NUMBER = '//*[@id="CARD_NUMBER"]'
  CREDIT_CARD_CRYPTO = '//*[@id="CVV_KEY"]'
  CREDIT_CARD_EXPIRE_MONTH = '//*[@id="contentSips"]/form[2]/select[1]'
  CREDIT_CARD_EXPIRE_YEAR = '//*[@id="contentSips"]/form[2]/select[2]'
  VALIDATE_PAYMENT = '//*[@id="contentSips"]/form[2]/input[9]'  
  TOTAL_ARTICLE = '//*[@id="dsprecap"]/div[4]/div[2]/div[2]/span'
  TOTAL_SHIPPING = '//*[@id="dsprecap"]/div[4]/div[2]/div[4]/span'
  TOTAL_TTC = '//*[@id="dsprecap"]/div[4]/div[2]/div[6]/span'
  
  def initialize context
    @context = context
  end
  
  def account
    Strategy.new(@context) do
      step(1) do
        open_url URL
        click_on_if_exists SKIP
        click_on MY_ACCOUNT
        fill EMAIL_CREATE, with:context[:user].email
        click_on CREATE_ACCOUNT
        fill PASSWORD_CREATE, with:context[:order].account_password
        fill PASSWORD_CONFIRM, with:context[:order].account_password
        select_option BIRTH_DAY, context[:user].birthday.day.to_s
        select_option BIRTH_MONTH, context[:user].birthday.month.to_s
        select_option BIRTH_YEAR, context[:user].birthday.year.to_s
        fill PHONE, with:context[:user].telephone
        click_on_radio context[:user].gender, {0 => CIVILITY_M, 1 =>  CIVILITY_MME, 2 =>  CIVILITY_MLLE}
        fill FIRSTNAME, with:context[:user].firstname
        fill LASTNAME, with:context[:user].lastname
        fill ADDRESS, with:context[:user].address
        fill POSTALCODE, with:context[:user].postalcode
        fill CITY, with:context[:user].city
        click_on VALIDATE_ACCOUNT_CREATION
      end
    end
  end
  
  def order
    Strategy.new(@context) do
      
      step(1) do
        open_url URL
        click_on_if_exists SKIP
        click_on MY_ACCOUNT
        fill EMAIL_LOGIN, with:context['user']['email']
        fill PASSWORD_LOGIN, with:context['order']['account_password']
        click_on LOGIN_BUTTON
        message Strategy::LOGGED_MESSAGE
      end
      
      step(2) do
        click_on MY_CART
        click_on_all([REMOVE_PRODUCT]) { |element| element || exists?(REMOVE_PRODUCT)}
        raise unless exists? EMPTY_CART_MESSAGE
        message Strategy::EMPTIED_CART_MESSAGE
      end
      
      step(3) do
        open_url context['order']['product_url']
        click_on ADD_TO_CART
        click_on ACCESS_CART
        click_on FINALIZE_ORDER
        click_on VALIDATE_SHIP_ADDRESS
        click_on VALIDATE_SHIPPING
        message = {
          Strategy::PRICE_KEY => get_text(TOTAL_ARTICLE), 
          Strategy::SHIPPING_PRICE_KEY => get_text(TOTAL_SHIPPING), 
          Strategy::TOTAL_TTC_KEY => get_text(TOTAL_TTC)
        }
        confirm message
      end
      
      step(4) do
        if context['response'] == Strategy::RESPONSE_OK
          click_on VALIDATE_CARD_PAYMENT
          click_on VALIDATE_VISA_CARD
          fill CREDIT_CARD_NUMBER, with:context['credentials']['card_number']
          fill CREDIT_CARD_CRYPTO, with:context['credentials']['card_crypto']
          select_option CREDIT_CARD_EXPIRE_MONTH, context['credentials']['expire_month']
          select_option CREDIT_CARD_EXPIRE_YEAR, context['credentials']['expire_year']
          click_on VALIDATE_PAYMENT
        end
        terminate
      end
    end
  end
end
