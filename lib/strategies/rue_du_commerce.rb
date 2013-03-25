module RueDuCommerce
  ACCOUNT = Strategy.new do 
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
  
  LOGIN = Strategy.new do
    open_url "http://m.rueducommerce.fr"
    click_on "menu"
    click_on "Mon compte"
    fill("Votre email", with: context[:account].email)
    fill("Votre mot de passe", with: context[:account].password)
    click_on "Se connecter"
  end
end
