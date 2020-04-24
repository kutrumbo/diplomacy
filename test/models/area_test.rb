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
end
