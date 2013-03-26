require 'test_helper'
require_lib 'driver'
require_lib 'strategy'

describe Strategy do
  
  before do
    @context = {}
  end
  
  after do
    `killall Google\\ Chrome` #osx
  end

  describe "dsl" do

    it "should respond to open_url" do
      strategy = Strategy.new(@context, Driver.new) do
        open_url "http://m.rueducommerce.fr"
      end
      assert strategy.run
    end
    
    it "sould respond to click on an element using its displayed text" do
      
      strategy = Strategy.new(@context, Driver.new) do
        open_url "http://m.rueducommerce.fr"
        click_on "menu"
      end
      assert strategy.run
    end
    
    it "should respond to fill an input with a given label name" do
      
      strategy = Strategy.new(@context, Driver.new) do
        open_url "http://m.rueducommerce.fr"
        click_on "menu"
        click_on "Mon compte"
        click_on "Créer son compte"
        fill("Prénom", with: "Philippe")
      end
      assert strategy.run
    end
    
    it "should respond to click on a radio button" do
      
      strategy = Strategy.new(@context, Driver.new) do
        open_url "http://m.rueducommerce.fr"
        click_on "menu"
        click_on "Mon compte"
        click_on "Créer son compte"
        click_on "M."
      end
      assert strategy.run
    end
    
    it "should be able to click on input button with a given text value" do
      
      strategy = Strategy.new(@context, Driver.new) do
        open_url "http://m.rueducommerce.fr"
        click_on "menu"
        click_on "Mon compte"
        click_on "Créer son compte"
        click_on "Créer un compte complet"
      end
      assert strategy.run
    end
    
    it 'should be able to click on element given by xpath' do
      
      strategy = Strategy.new(@context, Driver.new) do
        open_url "http://m.rueducommerce.fr"
        click_on :xpath => "//li[@class='cart']"
      end
      assert strategy.run
    end
    
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
