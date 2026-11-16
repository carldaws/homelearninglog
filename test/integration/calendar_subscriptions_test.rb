require "test_helper"

class CalendarSubscriptionsTest < ActionDispatch::IntegrationTest
  test "a grown-up's feed for a child needs no sign-in, just the link" do
    get feed_path(accesses(:alice_for_sam).calendar_token, format: :ics)

    assert_response :success
    assert_equal Mime[:ics], response.media_type
  end

  test "a made-up link finds nothing" do
    get feed_path("made-up", format: :ics)

    assert_response :not_found
  end

  test "each grown-up has their own link to the child's feed" do
    sign_in_as users(:alice)

    get child_calendar_subscription_path(children(:sam))

    assert_select "[data-share-url-value=?]", feed_url(accesses(:alice_for_sam).calendar_token, format: :ics)
  end

  test "a new link stops only your old one working" do
    sign_in_as users(:alice)
    old_token = accesses(:alice_for_sam).calendar_token

    patch child_calendar_subscription_path(children(:sam))

    assert_redirected_to child_calendar_subscription_path(children(:sam))
    get feed_path(old_token, format: :ics)
    assert_response :not_found
    get feed_path(accesses(:bob_for_sam).calendar_token, format: :ics)
    assert_response :success
  end

  test "a removed grown-up's feed stops working" do
    token = accesses(:bob_for_sam).calendar_token

    accesses(:bob_for_sam).destroy!

    get feed_path(token, format: :ics)
    assert_response :not_found
  end
end
