class Fnac
  
  def initialize driver, context
    @driver = driver
    @context = context
  end
  
  def account
    Strategy.new(@context, @driver) do 
      open_url "http://www.fnac.com/"
      click_on "Mon Compte"
      fill("RegistrationSteamRollPlaceHolder_ctl00_txtEmail", with:context[:user].email)
      fill("RegistrationSteamRollPlaceHolder_ctl00_txtPassword1", with:context[:password])
      fill("RegistrationSteamRollPlaceHolder_ctl00_txtPassword2", with:context[:password])
      click_on "Créez votre compte"
      click_on "RegistrationMemberId_registrationContainer_gender_rbGender_2"
      fill("RegistrationMemberId_registrationContainer_lastName_txtLastname", with:context[:user].lastname)
      fill("RegistrationMemberId_registrationContainer_firstName_txtFirstName", with:context[:user].firstname)
      select_option("RegistrationMemberId_registrationContainer_birthDate_dpBirthDate_ddlDay", context[:user].birthday.day.to_s.rjust(2, "0"))
      select_option("RegistrationMemberId_registrationContainer_birthDate_dpBirthDate_ddlMonth", context[:user].birthday.month.to_s.rjust(2, "0"))
      fill("RegistrationMemberId_registrationContainer_birthDate_dpBirthDate_txtYear", with:context[:user].birthday.year.to_s)
      click_on("RegistrationMemberId_registrationContainer_NewsLetterWithPref_chkTermsAndPreferences_Refuse")
      click_on("Créez votre compte")
    end
  end
  
  def login
    Strategy.new(@context, @driver) do
      open_url "http://www.fnac.com/"
      click_on "Mon Compte"
      fill("LogonAccountSteamRollPlaceHolder_ctl00_txtEmail", with:context[:user].email)
      fill("LogonAccountSteamRollPlaceHolder_ctl00_txtPassword", with: context[:password])
      click_on "Identifiez-vous"
    end
  end
  
  def order
    Strategy.new(@context, @driver) do
      open_url context[:order].product_url
      click_on "btn b_std_y btn_medium FnacBtnAddBasket", "a"
      open_url "http://www4.fnac.com/Account/Basket/IntermediaryShoppingCartRecalculate.aspx"
      # click_on "Mon panier"
    end
  end
  
end