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
end
