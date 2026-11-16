require "test_helper"

class EntriesTest < ActionDispatch::IntegrationTest
  test "a child's log shows their entries" do
    sign_in_as users(:alice)

    get child_path(children(:sam))

    assert_select "h1", text: children(:sam).name
    assert_select "##{dom_id(entries(:painting))}"
    assert_select "##{dom_id(entries(:moon))}"
    assert_select "##{dom_id(entries(:den))}", count: 0
    assert_select "h2", text: I18n.t("entries.days.today")
  end

  test "adding to the log" do
    sign_in_as users(:bob)

    assert_difference -> { children(:ivy).entries.count } do
      post child_entries_path(children(:ivy)), params: { entry: { notes: entries(:moon).notes, happened_on: Date.current, minutes: 30 } }
    end

    assert_redirected_to child_path(children(:ivy))
    entry = children(:ivy).entries.last
    assert_equal users(:bob), entry.author
    assert_equal 30, entry.minutes
  end

  test "adding photos to the log" do
    sign_in_as users(:alice)

    post child_entries_path(children(:sam)), params: { entry: { happened_on: Date.current,
      photos: [ fixture_file_upload("photo.jpg", "image/jpeg"), fixture_file_upload("photo.jpg", "image/jpeg") ] } }

    assert_redirected_to child_path(children(:sam))
    assert_equal 2, children(:sam).entries.last.photos.count
  end

  test "an empty entry isn't added" do
    sign_in_as users(:alice)

    assert_no_difference -> { Entry.count } do
      post child_entries_path(children(:sam)), params: { entry: { notes: "", happened_on: Date.current } }
    end

    assert_response :unprocessable_content
  end

  test "editing an entry" do
    sign_in_as users(:bob)

    patch child_entry_path(children(:sam), entries(:painting)), params: { entry: { notes: entries(:moon).notes, minutes: "" } }

    assert_redirected_to child_path(children(:sam))
    assert_equal entries(:moon).notes, entries(:painting).reload.notes
    assert_nil entries(:painting).minutes
  end

  test "removing a photo from an entry" do
    entry = entries(:painting)
    entry.photos.attach(io: file_fixture("photo.jpg").open, filename: "kept.jpg")
    entry.photos.attach(io: file_fixture("photo.jpg").open, filename: "removed.jpg")
    kept = entry.photos.find { it.filename.to_s == "kept.jpg" }
    sign_in_as users(:alice)

    patch child_entry_path(children(:sam), entry), params: { entry: { photos: [ kept.signed_id, "" ] } }

    assert_redirected_to child_path(children(:sam))
    assert_equal [ kept.blob ], entry.reload.photos.map(&:blob)
  end

  test "deleting an entry" do
    sign_in_as users(:bob)

    assert_difference -> { children(:sam).entries.count }, -1 do
      delete child_entry_path(children(:sam), entries(:painting))
    end

    assert_redirected_to child_path(children(:sam))
  end

  test "other children's logs are out of reach" do
    sign_in_as users(:alice)

    get child_path(children(:wren))
    assert_response :not_found

    post child_entries_path(children(:wren)), params: { entry: { notes: entries(:den).notes, happened_on: Date.current } }
    assert_response :not_found

    get edit_child_entry_path(children(:wren), entries(:den))
    assert_response :not_found

    delete child_entry_path(children(:wren), entries(:den))
    assert_response :not_found
    assert Entry.exists?(entries(:den).id)
  end

  test "an entry can't be reached through another of your children" do
    sign_in_as users(:alice)

    get edit_child_entry_path(children(:ivy), entries(:painting))

    assert_response :not_found
  end

  test "a child's grown-ups can see the photos in their log" do
    entries(:painting).photos.attach(io: file_fixture("photo.jpg").open, filename: "photo.jpg")
    photo = entries(:painting).photos.first
    sign_in_as users(:bob)

    get child_entry_photo_path(children(:sam), entries(:painting), photo, size: :thumbnail)

    assert_response :success
    assert_equal Mime[:webp], response.media_type
    assert response.cache_control[:private]
  end

  test "photos are private to the child's grown-ups" do
    entries(:painting).photos.attach(io: file_fixture("photo.jpg").open, filename: "photo.jpg")
    photo = entries(:painting).photos.first

    get child_entry_photo_path(children(:sam), entries(:painting), photo)
    assert_redirected_to new_session_path

    sign_in_as users(:carol)
    get child_entry_photo_path(children(:sam), entries(:painting), photo)
    assert_response :not_found
  end

  test "Active Storage's public URLs are switched off" do
    entries(:painting).photos.attach(io: file_fixture("photo.jpg").open, filename: "photo.jpg")
    blob = entries(:painting).photos.first.blob

    get "/rails/active_storage/blobs/redirect/#{blob.signed_id}/#{blob.filename}"

    assert_response :not_found
  end
end
