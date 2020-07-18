require 'test_helper'

class PositionServiceTest < ActiveSupport::TestCase

  def setup
    @game = create(:game)
    @england = create(:user_game, power: 'england', game: @game)
    @france = create(:user_game, power: 'france', game: @game)
    @brest = Area.find_by_name('Brest')
  end

  def create_position(area, type, user_game, power, dislodged, retreat_turn)
    position = create(:position, area: area, type: type, user_game: user_game, power: power, dislodged: dislodged, turn: retreat_turn)
    if dislodged
      order = create(:order, type: 'disband', position: position, from: position.area, to: position.area, turn: position.turn, user_game: position.user_game)
      create(:resolution, status: 'resolved', order: order)
    end
  end

  test "process disband during spring retreat" do
    retreat_turn = create(:turn, type: 'spring_retreat', game: @game)
    next_turn = create(:turn, type: 'fall', game: @game)
    capturing_position = create_position(@brest, 'fleet', @england, 'france', false, retreat_turn)
    dislodged_position = create_position(@brest, 'fleet', @france, 'france', true, retreat_turn)

    PositionService.process_resolutions(retreat_turn, next_turn)

    resulting_positions = next_turn.reload.positions.where(area: @brest)

    assert_equal(1, resulting_positions.count)
    resulting_position = resulting_positions.first
    assert_equal(@england, resulting_position.user_game)
    assert_equal(false, resulting_position.dislodged?)
    assert_equal('fleet', resulting_position.type)
    assert_equal('france', resulting_position.power)
  end

  test "process disband during fall retreat" do
    retreat_turn = create(:turn, type: 'fall_retreat', game: @game)
    next_turn = create(:turn, type: 'winter', game: @game)
    capturing_position = create_position(@brest, 'fleet', @england, 'france', false, retreat_turn)
    dislodged_position = create_position(@brest, 'fleet', @france, 'france', true, retreat_turn)

    PositionService.process_resolutions(retreat_turn, next_turn)

    resulting_positions = next_turn.reload.positions.where(area: @brest)

    assert_equal(1, resulting_positions.count)
    resulting_position = resulting_positions.first
    assert_equal(@england, resulting_position.user_game)
    assert_equal(false, resulting_position.dislodged?)
    assert_equal('fleet', resulting_position.type)
    assert_equal('england', resulting_position.power)
  end
end
