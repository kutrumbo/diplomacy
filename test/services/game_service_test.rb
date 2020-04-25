require 'test_helper'

class GameServiceTest < ActiveSupport::TestCase
  parallelize_setup do |worker|
      AreaService.seed_areas
  end

  parallelize_teardown do |worker|
    AreaService.teardown
  end

  test "validates number of users" do
    assert_raise RuntimeError do
      GameService.initiate_game('foo', create_list(:user, 6))
    end

    assert_raise RuntimeError do
      GameService.initiate_game('foo', create_list(:user, 8))
    end

    assert_nothing_raised do
      GameService.initiate_game('foo', create_list(:user, 7))
    end
  end

  test "creates the first turn" do
    GameService.initiate_game('foo', create_list(:user, 7))

    turns = Turn.all
    assert_equal(1, turns.count)
    first_turn = turns.first
    assert_equal('fall', first_turn.type)
    assert_equal(1, first_turn.number)
  end

  test "creates starting positions" do
    GameService.initiate_game('foo', create_list(:user, 7))

    assert_equal(42, Position.count)
  end
end
