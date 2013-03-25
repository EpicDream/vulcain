require 'test_helper'
require_lib 'driver'
require_lib 'strategy'
  
describe Strategy do
  
  before do
  end
  
  after do
    `killall Google\\ Chrome` #osx
  end

  describe "dsl" do
    it "should respond to open_url" do
      strategy = Strategy.new do
        open_url "http://m.rueducommerce.fr"
      end
      strategy.context = {}
      assert strategy.run
    end
    
    it "sould respond to click on an element using its displayed text" do
      strategy = Strategy.new do
        open_url "http://m.rueducommerce.fr"
        click_on "menu"
      end
      strategy.context = {}
      assert strategy.run
    end
    
    it "should respond to fill an input with a given label name" do
      strategy = Strategy.new do
        open_url "http://m.rueducommerce.fr"
        click_on "menu"
        click_on "Mon compte"
        click_on "Créer son compte"
        fill("Prénom", with: "Philippe")
      end
      strategy.context = {}
      assert strategy.run
    end
    
    it "should respond to click on a radio button" do
      strategy = Strategy.new do
        open_url "http://m.rueducommerce.fr"
        click_on "menu"
        click_on "Mon compte"
        click_on "Créer son compte"
        click_on "M."
      end
      strategy.context = {}
      assert strategy.run
    end
    
    it "should be able to click on input button with a given text value" do
      strategy = Strategy.new do
        open_url "http://m.rueducommerce.fr"
        click_on "menu"
        click_on "Mon compte"
        click_on "Créer son compte"
        click_on "Créer un compte complet"
      end
      strategy.context = {}
      assert strategy.run
    end
    
  end
  
end
