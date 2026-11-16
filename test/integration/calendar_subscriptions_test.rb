require "test_helper"

class CalendarSubscriptionsTest < ActionDispatch::IntegrationTest
  test "a child's feed needs no sign-in, just the link" do
    get feed_path(children(:sam).calendar_token, format: :ics)

    assert_response :success
    assert_equal Mime[:ics], response.media_type
  end

  test "a made-up link finds nothing" do
    get feed_path("made-up", format: :ics)

    assert_response :not_found
  end

  test "the subscription page links to the feed" do
    sign_in_as users(:alice)

    get child_calendar_subscription_path(children(:sam))

    assert_select "[data-share-url-value=?]", feed_url(children(:sam).calendar_token, format: :ics)
  end

  test "a new link stops the old one working" do
    sign_in_as users(:alice)
    old_token = children(:sam).calendar_token

    patch child_calendar_subscription_path(children(:sam))

    assert_redirected_to child_calendar_subscription_path(children(:sam))
    get feed_path(old_token, format: :ics)
    assert_response :not_found
  end
end
