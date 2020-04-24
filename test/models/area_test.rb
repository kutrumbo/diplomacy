require 'test_helper'

class AreaTest < ActiveSupport::TestCase
  test "validates type" do
    assert(build(:area, type: 'land').valid?)
    assert(build(:area, type: 'hill').invalid?)
  end
end
