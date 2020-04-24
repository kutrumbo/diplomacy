require 'test_helper'

class UserGameTest < ActiveSupport::TestCase
  test "validates power" do
    assert(build(:user_game, power: 'austria').valid?)
    assert(build(:user_game, power: 'america').invalid?)
  end
end
