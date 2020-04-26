require 'test_helper'

class TurnServiceTest < ActiveSupport::TestCase
  test "create_next_turn" do
    turn = create(:turn, number: 5, type: 'winter')
    next_turn = TurnService.create_next_turn(turn)

    assert_equal(6, next_turn.number)
    assert_equal('spring', next_turn.type)
    assert_equal(turn.game, next_turn.game)
  end

  test "victory?-true" do
    game = create(:game, :started)
    area_with_supply_center = create(:area, supply_center: true)

    create_list(:position, 18, area: area_with_supply_center, user_game: game.user_games.first)

    assert(TurnService.victory?(game))
  end

  test "victory?-false" do
    game = create(:game, :started)
    area_with_supply_center = create(:area, supply_center: true)
    area_without_supply_center = create(:area, supply_center: false)

    create_list(:position, 17, area: area_with_supply_center, user_game: game.user_games.first)
    create_list(:position, 2, area: area_without_supply_center, user_game: game.user_games.first)

    assert_not(TurnService.victory?(game))
  end

  test "create_support_map" do
    aegean_sea = Area.find_by_name('Aegean Sea')
    albania = Area.find_by_name('Albania')
    bulgaria = Area.find_by_name('Bulgaria')
    greece = Area.find_by_name('Greece')
    ionian_sea = Area.find_by_name('Ionian Sea')
    serbia = Area.find_by_name('Serbia')
    tunis = Area.find_by_name('Tunis')

    aegean_sea_position = create(:position, area: aegean_sea, type: 'fleet')
    albania_position = create(:position, area: albania, type: 'army')
    bulgaria_position = create(:position, area: bulgaria, type: 'army')
    greece_position = create(:position, area: greece, type: 'army')
    ionian_sea_position = create(:position, area: ionian_sea, type: 'fleet')
    serbia_position = create(:position, area: serbia, type: 'army')
    tunis_position = create(:position, area: tunis, type: 'army')

    create(:order, type: 'support', from: tunis, to: greece, position: aegean_sea_position)
    create(:order, type: 'convoy', from: tunis, to: greece, position: ionian_sea_position)
    create(:order, type: 'support', from: bulgaria, to: greece, position: serbia_position)
    albania_order = create(:order, type: 'move', from: albania, to: greece, position: albania_position)
    bulgaria_order = create(:order, type: 'move', from: bulgaria, to: greece, position: bulgaria_position)
    greece_order = create(:order, type: 'hold', from: greece, to: greece, position: greece_position)
    tunis_order = create(:order, type: 'move', from: tunis, to: greece, position: tunis_position)

    support_map = TurnService.create_support_map(Order.all)

    assert_equal(1, support_map.keys.count)
    assert_equal(greece, support_map.keys.first)
    assert_equal(4, support_map[greece].keys.count)
    assert_equal(0, support_map[greece][albania_order].count)
    assert_equal(1, support_map[greece][bulgaria_order].count)
    assert_equal(0, support_map[greece][greece_order].count)
    assert_equal(1, support_map[greece][tunis_order].count)
  end
end
