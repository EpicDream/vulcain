require File.join(File.dirname(__FILE__), 'xpaths')

class RueDuCommerce
  include RueDuCommerceXpaths
  
  def initialize driver, context
    @driver = driver
    @context = context
  end
  
  def account
    Strategy.new(@context, @driver) do 
      open_url URL
      click_on_if_exists SKIP
      click_on MY_ACCOUNT
      fill EMAIL_CREATE, with:context[:user].email
      click_on CREATE_ACCOUNT
      fill PASSWORD_CREATE, with:context[:password]
      fill PASSWORD_CONFIRM, with:context[:password]
      select_option BIRTH_DAY_SELECT, context[:user].birthday.day.to_s
      select_option BIRTH_MONTH_SELECT, context[:user].birthday.month.to_s
      select_option BIRTH_YEAR_SELECT, context[:user].birthday.year.to_s
      fill PHONE, with:context[:user].telephone
      case context[:user].gender
      when 0 then click_on CIVILITY_M
      when 1 then click_on CIVILITY_MME
      when 2 then click_on CIVILITY_MLLE
      end
      fill FIRSTNAME, with:context[:user].firstname
      fill LASTNAME, with:context[:user].lastname
      fill ADDRESS, with:context[:user].address
      fill POSTALCODE, with:context[:user].postalcode
      fill CITY, with:context[:user].city
      click_on VALIDATE_ACCOUNT_CREATION
    end
  end
  
  def login
    Strategy.new(@context, @driver) do
      open_url URL
      click_on_if_exists SKIP
      click_on MY_ACCOUNT
      fill EMAIL_LOGIN, with:context[:user].email
      fill PASSWORD_LOGIN, with:context[:password]
      click_on LOGIN_BUTTON
    end
  end
  
  def order
    Strategy.new(@context, @driver) do
      #ensure empty cart
      click_on MY_CART
      click_on_all REMOVE_PRODUCT
      raise unless assert_element EMPTY_CART_MESSAGE
      
      #order
      open_url context[:order].product_url
      click_on ADD_TO_CART
      click_on ACCESS_CART
      click_on FINALIZE_ORDER
      click_on VALIDATE_SHIP_ADDRESS
      click_on VAIDATE_SHIPPING
      click_on VALIDATE_CARD_PAYMENT
      click_on VALIDATE_VISA_CARD
      fill CREDIT_CARD_NUMBER, with:context[:order].card_number
      fill CREDIT_CARD_CRYPTO, with:context[:order].card_crypto
      select_option CREDIT_CARD_EXPIRE_MONTH, context[:order].expire_month
      select_option CREDIT_CARD_EXPIRE_YEAR, context[:order].expire_year
      click_on VALIDATE_PAYMENT
    end
  end
end
