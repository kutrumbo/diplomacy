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

  test "validates unit" do
    assert(build(:area, unit: 'army').valid?)
    assert(build(:area, unit: 'fleet').valid?)
    assert(build(:area, unit: nil).valid?)
    assert(build(:area, unit: 'solider').invalid?)
  end

  test "validates coast" do
    assert(build(:area, coast: 'south').valid?)
    assert(build(:area, coast: nil).valid?)
    assert(build(:area, coast: 'west').invalid?)
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
