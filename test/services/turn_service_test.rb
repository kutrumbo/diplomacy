require 'test_helper'

class TurnServiceTest < ActiveSupport::TestCase
  test "create_next_turn" do
    turn = create(:turn, number: 5, type: 'winter')
    next_turn = TurnService.create_next_turn(turn)

    assert_equal(6, next_turn.number)
    assert_equal('spring', next_turn.type)
    assert_equal(turn.game, next_turn.game)
  end

  test "determine_victor-true" do
    game = create(:game, :started)
    user_game = game.user_games.first
    area_with_supply_center = create(:area, supply_center: true)

    create_list(:position, 18, area: area_with_supply_center, user_game: user_game, power: user_game.power)

    assert(TurnService.determine_victor(game))
  end

  test "determine_victor-false" do
    game = create(:game, :started)
    user_game = game.user_games.first
    area_with_supply_center = create(:area, supply_center: true)
    area_without_supply_center = create(:area, supply_center: false)

    create_list(:position, 17, area: area_with_supply_center, user_game: user_game, power: user_game.power)
    create_list(:position, 2, area: area_without_supply_center, user_game: user_game, power: user_game.power)

    assert_not(TurnService.determine_victor(game))
  end
end
