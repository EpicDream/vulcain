# encoding: utf-8

if defined?(Driver)
  Object.send(:remove_const, :Driver)
end

if defined?(Strategy)
  Object.send(:remove_const, :Strategy)
end

if defined?(Amazon)
  Object.send(:remove_const, :Amazon)
end

require "selenium-webdriver"
require "headless"

$selenium_headless_runner = Headless.new
$selenium_headless_runner.start

class Driver
  USER_AGENT = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.60 Safari/537.17"
  TIMEOUT = 20
  MAX_ATTEMPTS_ON_RAISE = 20
  
  attr_accessor :driver, :wait
  
  def initialize options={}
    @driver = Selenium::WebDriver.for :chrome, :switches => ["--user-agent=#{options[:user_agent] || USER_AGENT}"]
    @wait = Selenium::WebDriver::Wait.new(:timeout => TIMEOUT)
    @attempts = 0
    @driver.manage.delete_all_cookies
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
    options = options_of_select(select)
    options.each do |option|
      next unless option.attribute("value") == value
      option.click
      break
    end
  end
  
  def options_of_select select
    select.find_elements(:tag_name, "option")
  end
  
  def click_on element
    waiting { element.click }
  end
  
  def find_element xpath, options={}
    return driver.find_elements(:xpath => xpath).first if options[:nowait]
    waiting { driver.find_elements(:xpath => xpath).first }
  end
  
  def find_elements xpath
    waiting { driver.find_elements(:xpath => xpath) }
  end
  
  def find_any_element xpaths
    waiting { 
      xpaths.inject(nil) do |element, xpath|
        element = driver.find_elements(:xpath => xpath).first 
        break element if element
        element
      end
    }
  end
  
  def find_links_with_text text
    waiting { driver.find_elements(:link_text => text) }
  end
  
  def find_input_with_value value
    waiting { driver.find_element(:xpath => "//input[@value='#{value}']")}
  end
  
  private
  
  def waiting
    wait.until do 
      begin
        yield
      rescue => e
        if (@attempts += 1) <= MAX_ATTEMPTS_ON_RAISE
          sleep(0.1) and retry
        else
          puts e.inspect
          @attempts = 0
          raise
        end
      end  
    end
  end
  
end

# encoding: utf-8
require 'ostruct'

class Strategy
  LOGGED_MESSAGE = 'logged'
  EMPTIED_CART_MESSAGE = 'cart emptied'
  CART_FILLED = 'cart filled'
  PRICE_KEY = 'price'
  SHIPPING_PRICE_KEY = 'shipping_price'
  TOTAL_TTC_KEY = 'total_ttc'
  RESPONSE_OK = 'ok'
  MESSAGES_VERBS = {:ask => 'ask', :message => 'message', :terminate => 'success', :next_step => 'next_step'}
  PRODUCT_KEYS = [:shipping_text, :price_text, :title, :image_url, :shipping, :price]
  
  attr_accessor :context, :exchanger, :self_exchanger, :driver
  attr_accessor :account, :order, :user, :questions, :answers, :steps_options, :products
  
  def initialize context, &block
    @driver = Driver.new
    @block = block
    self.context = context
    @next_step = nil
    @steps = {}
    @steps_options = []
    @questions = {}
    @product_url_index = 0
    @products = []
    self.instance_eval(&@block)
  end
  
  def start
    @steps['run'].call
  end
  
  def next_step args=nil
    @steps[@next_step].call(args)
  end
  
  def run_step name
    @steps[name].call
  end
  
  def step name, &block
    @steps[name] = block
  end
  
  def run
    run_step('run')
  end
  
  def ask message, state={}
    @next_step = state[:next_step]
    message = {'verb' => MESSAGES_VERBS[:ask], 'content' => message}
    exchanger.publish(message, @session)
  end
  
  def message message, state={}
    @next_step = state[:next_step]
    message = {'verb' => MESSAGES_VERBS[:message], 'content' => message}
    exchanger.publish(message, @session)
    if @next_step
      message = {'verb' => MESSAGES_VERBS[:next_step]}
      self_exchanger.publish(message, @session)
    end
  end
  
  def terminate
    message = {'verb' => MESSAGES_VERBS[:terminate]}
    @driver.quit
    exchanger.publish(message, @session)
  end
  
  def next_product_url
    order.products_urls[(@product_url_index += 1) - 1]
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
  
  def click_on_links_with_text text, &block
    elements = @driver.find_links_with_text text
    elements.each do |element| 
      @driver.click_on element
      block.call if block_given?
    end
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
  
  def click_on_button_with_name name
    button = @driver.find_input_with_value(name)
    @driver.click_on button
  end
  
  def find_any_element xpaths
    @driver.find_any_element xpaths
  end
  
  def find_elements xpath
    @driver.find_elements xpath
  end
  
  def find_element xpath
    find_elements(xpath).first
  end
  
  def image_url xpath
    element = find_element(xpath)
    element.attribute('src') if element
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
  
  def options_of_select xpath
    select = @driver.find_element(xpath)
    options = @driver.options_of_select select
    options.inject({}) do |options, option|
      options.merge!({option.attribute("value") => option.text})
    end
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
  
  def context=context
    @context ||= {}
    @context = @context.merge!(context)
    ['account', 'order', 'answers', 'user'].each do |ivar|
      next unless context[ivar]
      instance_variable_set "@#{ivar}", object_to_openstruct(context[ivar])
    end
    @session = context['session']
  end
  
  private
  
  def object_to_openstruct(object)
    case object
    when Hash
      object = object.clone
      object.each do |key, value|
        object[key] = object_to_openstruct(value)
      end
      OpenStruct.new(object)
    when Array
      object = object.clone
      object.map! { |i| object_to_openstruct(i) }
    else
      object
    end
  end
  
end
# encoding: utf-8

class Amazon
  URL = 'http://www.amazon.fr/'
  REGISTER_URL = 'https://www.amazon.fr/ap/register?_encoding=UTF8&openid.assoc_handle=frflex&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.mode=checkid_setup&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.ns.pape=http%3A%2F%2Fspecs.openid.net%2Fextensions%2Fpape%2F1.0&openid.pape.max_auth_age=0&openid.return_to=https%3A%2F%2Fwww.amazon.fr%2Fgp%2Fyourstore%2Fhome%3Fie%3DUTF8%26ref_%3Dgno_newcust'
  REGISTER_NAME = '//*[@id="ap_customer_name"]'
  REGISTER_EMAIL = '//*[@id="ap_email"]'
  REGISTER_EMAIL_CONFIRMATION = '//*[@id="ap_email_check"]'
  REGISTER_PASSWORD = '//*[@id="ap_password"]'
  REGISTER_PASSWORD_CONFIRMATION = '//*[@id="ap_password_check"]'
  REGISTER_SUBMIT = '//*[@id="continue"]'
  LOGIN_BUTTON = '//*[@id="nav-your-account"]/span[1]/span/span[2]'
  LOGIN_EMAIL = '//*[@id="ap_email"]'
  LOGIN_PASSWORD = '//*[@id="ap_password"]'
  LOGIN_SUBMIT = '//*[@id="signInSubmit"]'
  UNLOG_URL = 'http://www.amazon.fr/gp/flex/sign-out.html/ref=gno_signout?ie=UTF8&action=sign-out&path=%2Fgp%2Fyourstore%2Fhome&signIn=1&useRedirectOnSuccess=1'
  ADD_TO_CART = '//*[@id="bb_atc_button" or @id="addToCartButton"]'
  ACCESS_CART = '//*[@id="nav-cart"]/span[1]/span/span[3]'
  DELETE_LINK_NAME = 'Supprimer'
  EMPTIED_CART_MESSAGE = '//*[@id="cart-active-items"]/div[2]/h3'
  ORDER_BUTTON_NAME = 'Passer la commande'
  ORDER_PASSWORD = '//*[@id="ap_password"]'
  ORDER_LOGIN_SUBMIT = '//*[@id="signInSubmit"]'
  NEW_ADDRESS_TITLE = '//*[@id="newShippingAddressFormFromIdentity"]/div[1]/div'
  SHIPMENT_FORM_NAME = '//*[@id="enterAddressFullName"]'
  SHIPMENT_ADDRESS_1 = '//*[@id="enterAddressAddressLine1"]'
  SHIPMENT_ADDRESS_2 = '//*[@id="enterAddressAddressLine2"]'
  ADDITIONAL_ADDRESS = '//*[@id="GateCode"]'
  SHIPMENT_CITY = '//*[@id="enterAddressCity"]'
  SHIPMENT_ZIP = '//*[@id="enterAddressPostalCode"]'
  SHIPMENT_PHONE = '//*[@id="enterAddressPhoneNumber"]'
  SHIPMENT_SUBMIT = '//*[@id="newShippingAddressFormFromIdentity"]/div[1]/div/form/div[6]/span/span/input'
  SHIPMENT_CONTINUE = '//*[@id="continue"] | //*[@id="shippingOptionFormId"]/div[1]/div[2]/div/span/span/input'
  SHIPMENT_ORIGINAL_ADDRESS_OPTION = '//*[@id="addr_0"]'
  SHIPMENT_FACTURATION_CHOICE_SUBMIT= '//*[@id="AVS"]/div[2]/form/div/div[2]/div/div/div/span/input'
  SHIPMENT_SEND_TO_THIS_ADDRESS = '/html/body/div[4]/div[2]/form/div/div[1]/div[2]/span/a'
  SELECT_SIZE = '//*[@id="dropdown_size_name"]'
  SELECT_COLOR = '//*[@id="selected_color_name"]'
  COLORS = '//div[@key="color_name"]'
  COLOR_SELECTOR = lambda { |id| "//*[@id='color_name_#{id}']"}
  UNAVAILABLE_COLORS = '//div[@class="swatchUnavailable"]'
  OPEN_SESSION_TITLE = '//*[@id="ap_signin1a_pagelet"]'
  PRICE_PLUS_SHIPPING = '//*[@id="BBPricePlusShipID"]'
  PRICE = '//*[@id="priceBlock"]'
  TITLE = '//*[@id="btAsinTitle"]'
  IMAGE = '//*[@id="original-main-image"]'
  
  attr_accessor :context, :strategy
  
  def initialize context
    @context = context
    @strategy = instanciate_strategy
  end
  
  def instanciate_strategy
    Strategy.new(@context) do

      step('run') do
        run_step('create account') if account.new_account
        run_step('unlog')
        run_step('login')
      end
      
      step('create account') do
        open_url REGISTER_URL
        fill REGISTER_NAME, with:"#{user.first_name} #{user.last_name}"
        fill REGISTER_EMAIL, with:account.login
        fill REGISTER_EMAIL_CONFIRMATION, with:account.login
        fill REGISTER_PASSWORD, with:account.password
        fill REGISTER_PASSWORD_CONFIRMATION, with:account.password
        click_on REGISTER_SUBMIT
      end
      
      step('unlog') do
        open_url UNLOG_URL
      end
      
      step('login') do
        open_url URL
        click_on LOGIN_BUTTON
        fill LOGIN_EMAIL, with:account.login
        fill LOGIN_PASSWORD, with:account.password
        click_on LOGIN_SUBMIT
        message Strategy::LOGGED_MESSAGE, :next_step => 'empty cart'
      end
      
      step('size option') do
        options = options_of_select(SELECT_SIZE)
        options.delete_if { |value, text| value == "-1"}
        questions.merge!({'1' => "select_option('#{SELECT_SIZE}', answer)"})
        { :text => "Choix de la taille", :id => "1", :options => options }
      end
      
      step('color option') do
        colors = find_elements(COLORS).inject({}) do |colors, element|
          hash = { element.attribute('count') => element.attribute('title').gsub(/Cliquez pour sélectionner /, '') }
          colors.merge!(hash)
        end
        unavailable = find_elements(UNAVAILABLE_COLORS).map do |element|
          element.attribute('id').gsub(/color_name_/, '')
        end
        colors.delete_if { |id, title|  unavailable.include?(id)}
        questions.merge!({'2' => "click_on(COLOR_SELECTOR.(answer))"})
        { :text => "Choix de la couleur", :id => "2", :options => colors }
      end
      
      step('select options') do
        if steps_options.none?
          sleep(1)
          click_on ADD_TO_CART
          run_step 'add to cart'
        else
          message = {:questions => []}
          question = run_step(steps_options.shift)
          message[:questions] << question 
          ask message, next_step:'select option'
        end
      end
      
      step('select option') do
        raise unless answers || answers.any?
        answers.each do |_answer|
          answer = _answer.answer
          action = questions[_answer.question_id]
          eval(action)
        end
        run_step('select options')
      end
      
      step('build product') do
        product = Hash.new
        product['shipping_text'] = get_text(PRICE_PLUS_SHIPPING) if exists? PRICE_PLUS_SHIPPING
        product['price_text'] = get_text(PRICE).gsub(/Détails/i, '')
        product['title'] = get_text TITLE
        product['image_url'] = image_url(IMAGE)
        product['shipping'] = (product['shipping_text'] =~ /\+\s+EUR\s+([\d,]+)/i and $1.gsub(/,/,'.').to_f) || 0
        product['price'] = (product['price_text'] =~ /([\d,]+)/i and $1.gsub(/,/,'.').to_f)
        products << product
      end
      
      step('add to cart') do
        if url = next_product_url
          open_url url
          wait_for([ADD_TO_CART])
          run_step('build product')
          
          steps_options << 'size option' if exists?(SELECT_SIZE)
          steps_options << 'color option' if exists?(SELECT_COLOR)
          
          if steps_options.empty?
            click_on ADD_TO_CART
            run_step 'add to cart'
          else
            run_step('select options')
          end
        else
          message Strategy::CART_FILLED, :next_step => 'finalize order'
        end
      end
      
      step('empty cart') do
        click_on ACCESS_CART
        click_on_links_with_text(DELETE_LINK_NAME) do
          sleep(1)
        end
        click_on ACCESS_CART
        wait_for([EMPTIED_CART_MESSAGE])
        raise unless get_text(EMPTIED_CART_MESSAGE) =~ /panier\s+est\s+vide/i
        message Strategy::EMPTIED_CART_MESSAGE, :next_step => 'add to cart'
      end
      
      step('fill shipping form') do
        fill SHIPMENT_FORM_NAME, with:"#{user.first_name} #{user.last_name}"
        fill SHIPMENT_ADDRESS_1, with:user.address.address_1
        fill SHIPMENT_ADDRESS_2, with:user.address.address_2
        fill ADDITIONAL_ADDRESS, with:user.address.additionnal_address
        fill SHIPMENT_CITY, with:user.address.city
        fill SHIPMENT_ZIP, with:user.address.zip
        fill SHIPMENT_PHONE, with:user.mobile_phone
        click_on SHIPMENT_SUBMIT
        find_any_element([SHIPMENT_CONTINUE, SHIPMENT_ORIGINAL_ADDRESS_OPTION])
        if exists? SHIPMENT_FACTURATION_CHOICE_SUBMIT
          click_on SHIPMENT_ORIGINAL_ADDRESS_OPTION
          click_on SHIPMENT_FACTURATION_CHOICE_SUBMIT
        end
      end
      
      step('finalize order') do
        click_on ACCESS_CART
        click_on_button_with_name ORDER_BUTTON_NAME
        fill ORDER_PASSWORD, with:account.password
        click_on ORDER_LOGIN_SUBMIT
        wait_for [NEW_ADDRESS_TITLE]
        if exists? SHIPMENT_SEND_TO_THIS_ADDRESS
          click_on SHIPMENT_SEND_TO_THIS_ADDRESS
        else
          run_step 'fill shipping form'
        end
        click_on SHIPMENT_CONTINUE
        run_step('payment')
      end
      
      step('payment') do
        message({products:products})
        terminate
      end
      
    end
  end
  
end