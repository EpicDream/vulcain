require 'test_helper'
require_lib 'strategies/rue_du_commerce'

describe RueDuCommerce do
  
  before do
    @context = {}
  end
  
  after do
    `killall Google\\ Chrome` #osx
  end

  describe "Rue du Commerce strategy" do
    it 'should empty basket before order' do
      strategy = Strategy.new(@context, Driver.new) do
        open_url "http://m.rueducommerce.fr"
        click_on "menu"
        click_on "Mon compte"
        fill("Votre email", with: "madmax_1181@yopmail.com")
        fill("Votre mot de passe", with:"shopelia")
        click_on "Se connecter"
        
        open_url "http://m.rueducommerce.fr/fiche-produit/Galaxytab2-P5110-16Go-Blanc-OP"
        click_on "Ajouter au panier"
        click_on "Accéder à mon panier"
        
        wait_for ["Finaliser ma commande", "Votre panier est vide"]
        click_on_all "//a[@class='delete-fav-search']" do
          wait_for ["Finaliser ma commande", "Votre panier est vide"]
        end
        assert_element "Votre panier est vide"
      end
      
      assert strategy.run
    end
  end
  
end