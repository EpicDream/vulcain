require 'test_helper'
require_lib 'strategy'
  
describe Strategy do
  
  before do
  end
  
  after do
    puts `killall Google\\ Chrome`
  end

  describe "dsl" do
    it "should respond to open_url" do
      Strategy.new do
        open_url "http://m.rueducommerce.fr"
      end
    end
  end
  
  describe "it should respond to click on dom element display name" do
    Strategy.new do
      open_url "http://m.rueducommerce.fr"
      click_on "Menu"
    end
  end
  
end
