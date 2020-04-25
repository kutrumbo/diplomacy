require 'test_helper'

class AreaTest < ActiveSupport::TestCase
  test "validates type" do
    assert(build(:area, type: 'land').valid?)
    assert(build(:area, type: 'coast').invalid?)
  end

  test "validates power" do
    assert(build(:area, power: 'austria').valid?)
    assert(build(:area, power: 'america').invalid?)
  end

  test "coastal?" do
    ocean = create(:area, type: 'sea')
    sea = create(:area, type: 'sea')
    land = create(:area, type: 'land')
    coast = create(:area, type: 'land', neighboring_areas: [land, sea])
    sea.neighboring_areas << [coast, ocean]
    land.neighboring_areas << coast

    assert_not(sea.coastal?)
    assert_not(land.coastal?)
    assert(coast.coastal?)
  end
end
