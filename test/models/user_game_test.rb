require 'test_helper'

class UserGameTest < ActiveSupport::TestCase
  test "validates power" do
    assert(build(:user_game, power: 'austria').valid?)
    assert(build(:user_game, power: 'america').invalid?)
  end

  test "validates power uniqueness within game" do
    game = create(:game)
    create(:user_game, power: 'austria', game: game)
    create(:user_game, power: 'russia', game: game)

    assert(build(:user_game, power: 'austria', game: game).invalid?)
    assert(build(:user_game, power: 'austria', game: create(:game)).valid?)
  end
end
