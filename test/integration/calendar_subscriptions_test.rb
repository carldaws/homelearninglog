require "test_helper"

class CalendarSubscriptionsTest < ActionDispatch::IntegrationTest
  test "the family's feed needs no sign-in, just the link" do
    get feed_path(families(:oaks).calendar_token, format: :ics)

    assert_response :success
    assert_equal Mime[:ics], response.media_type
  end

  test "a made-up link finds nothing" do
    get feed_path("made-up", format: :ics)

    assert_response :not_found
  end

  test "the subscription page links to the feed" do
    sign_in_as users(:alice)

    get calendar_subscription_path

    assert_select "[data-share-url-value=?]", feed_url(families(:oaks).calendar_token, format: :ics)
  end

  test "a new link stops the old one working" do
    sign_in_as users(:alice)
    old_token = families(:oaks).calendar_token

    patch calendar_subscription_path

    assert_redirected_to calendar_subscription_path
    get feed_path(old_token, format: :ics)
    assert_response :not_found
  end
end
