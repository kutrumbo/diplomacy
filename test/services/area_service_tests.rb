require 'test_helper'

class AreaServiceTest < ActiveSupport::TestCase
  parallelize_setup do |worker|
      AreaService.seed_areas
  end

  parallelize_teardown do |worker|
    AreaService.teardown
  end

  test "coasts" do
    assert_equal(42, Area.coastal.count)
  end

  test "land-locked" do
    assert_equal(14, Area.land.without(Area.coastal).count)
  end

  test "sea" do
    assert_equal(19, Area.sea.count)
  end

  test "has_coasts" do
    assert_equal(3, Area.has_coasts.count)
  end

  test "supply_center" do
    assert_equal(34, Area.supply_center.count)
  end

  test "unit" do
    assert_equal(13, Area.starting_army.count)
    assert_equal(9, Area.starting_fleet.count)
  end

  test "power" do
    assert_equal(6, Area.starting_power('austria').count)
    assert_equal(6, Area.starting_power('england').count)
    assert_equal(6, Area.starting_power('france').count)
    assert_equal(6, Area.starting_power('germany').count)
    assert_equal(6, Area.starting_power('italy').count)
    assert_equal(7, Area.starting_power('russia').count)
    assert_equal(5, Area.starting_power('turkey').count)
  end
end
