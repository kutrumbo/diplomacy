require 'test_helper'

class TurnTest < ActiveSupport::TestCase
  test "validates type" do
    assert(build(:turn, type: 'fall').valid?)
    assert(build(:turn, type: 'fall_build').invalid?)
  end
end
