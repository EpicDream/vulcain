module RueDuCommerceXpaths
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
  BIRTH_DAY_SELECT = '//*[@id="content"]/form/div/div[2]/div/div[7]/select[1]'
  BIRTH_MONTH_SELECT = '//*[@id="content"]/form/div/div[2]/div/div[7]/select[2]'
  BIRTH_YEAR_SELECT = '//*[@id="content"]/form/div/div[2]/div/div[7]/select[3]'
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
  VAIDATE_SHIPPING = '//*[@id="btnValidContinue"]'
  VALIDATE_CARD_PAYMENT = '//*[@id="inpMop1"]'
  VALIDATE_VISA_CARD = '//*[@id="content"]/div/form/div[1]/input[2]'
  CREDIT_CARD_NUMBER = '//*[@id="CARD_NUMBER"]'
  CREDIT_CARD_CRYPTO = '//*[@id="CVV_KEY"]'
  CREDIT_CARD_EXPIRE_MONTH = '//*[@id="contentSips"]/form[2]/select[1]'
  CREDIT_CARD_EXPIRE_YEAR = '//*[@id="contentSips"]/form[2]/select[2]'
  VALIDATE_PAYMENT = '//*[@id="contentSips"]/form[2]/input[9]'
end
