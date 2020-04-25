require 'test_helper'

class PositionTest < ActiveSupport::TestCase
  test "validates type" do
    assert(build(:position, type: 'army').valid?)
    assert(build(:position, type: 'solider').invalid?)
    assert(build(:position, type: nil).valid?)
  end
end
