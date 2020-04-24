require 'test_helper'

class CoastTest < ActiveSupport::TestCase
  test "validates direction" do
    assert(build(:coast, direction: 'north').valid?)
    assert(build(:coast, direction: 'west').invalid?)
  end
end
