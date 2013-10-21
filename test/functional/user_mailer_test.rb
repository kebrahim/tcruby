require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "weekly_pick" do
    mail = UserMailer.weekly_pick
    assert_equal "Weekly pick", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
