require 'test_helper'

describe Strategy do
  
  before do
    @context = {}
  end
  
  after do
    `killall Google\\ Chrome` #osx
  end

  describe "dsl" do
   
    it "should respond to open_url, fill input, select option, click_on : radio_button, links with label" do
      strategy = Strategy.new(@context, Driver.new) do
        open_url "http://m.rueducommerce.fr"
        click_on "menu"
        click_on "Mon compte"
        click_on "Créer son compte"
        fill("Prénom", with: "Philippe")
        click_on "M."
        click_on "Créer un compte complet"
      end
      assert strategy.run
    end
    
    it 'should be able to click on element given by xpath' do
      skip
      strategy = Strategy.new(@context, Driver.new) do
        open_url "http://m.rueducommerce.fr"
        click_on :xpath => "//li[@class='cart']"
      end
      assert strategy.run
    end
    
  end
  
end
