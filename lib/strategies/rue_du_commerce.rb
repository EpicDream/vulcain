class RueDuCommerce
  
  def initialize driver, context
    @driver = driver
    @context = context
  end
  
  def account
    Strategy.new(@context, @driver) do 
      open_url "http://m.rueducommerce.fr"
      click_on "menu"
      click_on "Mon compte"
      click_on "Créer son compte"
      case context[:user].gender
      when 0 then click_on "M."
      when 1 then click_on "Mme"
      when 2 then click_on "Mlle"
      end
      fill("Prénom", with: context[:user].firstname)
      fill("Nom", with: context[:user].lastname)
      fill("E-mail", with: context[:user].email)
      fill("Mot de passe", with: context[:password])
      fill("Re-saisissez le mot de passe", with: context[:password])
      click_on "Créer un compte complet"
      fill("Adresse", with: context[:user].address)
      fill("Ville", with: context[:user].city)
      fill("Code postal", with: context[:user].postalcode)
      select_option("Jour", context[:user].birthday.day.to_s.rjust(2, "0"))
      select_option("Mois", context[:user].birthday.month.to_s.rjust(2, "0"))
      select_option("Année", context[:user].birthday.year.to_s.rjust(2, "0"))
      click_on "Valider"
    end
  end
  
  def login
    Strategy.new(@context, @driver) do
      open_url "http://m.rueducommerce.fr"
      click_on "menu"
      click_on "Mon compte"
      fill("Votre email", with: context[:account].email)
      fill("Votre mot de passe", with: context[:account].password)
      click_on "Se connecter"
    end
  end
  
  def order
    Strategy.new(@context, @driver) do
      click_on :xpath => "//li[@class='cart']"
      wait_for ["Finaliser ma commande", "Votre panier est vide"]
      click_on_all "//a[@class='delete-fav-search']" do
        wait_for ["Finaliser ma commande", "Votre panier est vide"]
      end
      raise unless assert_element("Votre panier est vide")
      
      open_url context[:order].product_url
      click_on "Ajouter au panier"
      click_on "Accéder à mon panier"
      click_on "Finaliser ma commande"
      click_on "Choix du transporteur"
      click_on "Récapitulatif de commande"
      click_on "Finaliser ma commande"
      click_on_image "http://paiement-public.rueducommerce.fr/images/mobile/mop_1.png"
      click_on_image "/logo/mobile/VISA.png"
      fill("CARD_NUMBER", with:context[:order].card_number)
      fill("CVV_KEY", with:context[:order].card_crypto)
      select_option "CARD_VAL_MONTH", context[:order].expire_month
      select_option "CARD_VAL_YEAR", context[:order].expire_year
      click_on "VALIDER"
    end
  end
end
