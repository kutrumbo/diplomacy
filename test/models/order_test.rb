require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  test "validates type" do
    assert(build(:order, type: 'move').valid?)
    assert(build(:order, type: 'attack').invalid?)
  end
end
