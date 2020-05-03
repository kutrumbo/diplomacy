require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "lowercases email" do
    assert_equal('foo@gmail.com', create(:user, email: 'FOO@gmail.com').email)
  end
end
