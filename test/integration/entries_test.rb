require "test_helper"

class EntriesTest < ActionDispatch::IntegrationTest
  test "the log shows the family's entries" do
    sign_in_as users(:alice)

    get entries_path

    assert_select "##{dom_id(entries(:painting))}"
    assert_select "##{dom_id(entries(:moon))}"
    assert_select "##{dom_id(entries(:den))}", count: 0
    assert_select "h2", text: I18n.t("entries.days.today")
  end

  test "a family without children is asked to add them first" do
    sign_in_as users(:carol)
    entries(:den).destroy!
    events(:swimming).destroy!
    children(:wren).destroy!

    get entries_path

    assert_select "a[href=?]", new_family_child_path
    assert_select "a[href=?]", new_entry_path, count: 0
  end

  test "a family without children is sent to add one before logging" do
    sign_in_as users(:carol)
    entries(:den).destroy!
    events(:swimming).destroy!
    children(:wren).destroy!

    get new_entry_path

    assert_redirected_to new_family_child_path
  end

  test "adding to the log" do
    sign_in_as users(:bob)

    assert_difference -> { families(:oaks).entries.count } do
      post entries_path, params: { entry: { notes: entries(:moon).notes, happened_on: Date.current, minutes: 30, child_ids: [ children(:ivy).id ] } }
    end

    assert_redirected_to entries_path
    entry = families(:oaks).entries.last
    assert_equal users(:bob), entry.author
    assert_equal [ children(:ivy) ], entry.children
    assert_equal 30, entry.minutes
  end

  test "adding photos to the log" do
    sign_in_as users(:alice)

    post entries_path, params: { entry: { happened_on: Date.current, child_ids: [ children(:sam).id ],
      photos: [ fixture_file_upload("photo.jpg", "image/jpeg"), fixture_file_upload("photo.jpg", "image/jpeg") ] } }

    assert_redirected_to entries_path
    assert_equal 2, families(:oaks).entries.last.photos.count
  end

  test "an empty entry isn't added" do
    sign_in_as users(:alice)

    assert_no_difference -> { Entry.count } do
      post entries_path, params: { entry: { notes: "", happened_on: Date.current, child_ids: [ children(:sam).id ] } }
    end

    assert_response :unprocessable_content
  end

  test "entries can't be about another family's children" do
    sign_in_as users(:alice)

    assert_no_difference -> { Entry.count } do
      post entries_path, params: { entry: { notes: entries(:den).notes, happened_on: Date.current, child_ids: [ children(:wren).id ] } }
    end

    assert_response :unprocessable_content
  end

  test "an entry can't be changed to be about another family's child" do
    sign_in_as users(:alice)

    patch entry_path(entries(:painting)), params: { entry: { child_ids: [ children(:wren).id ] } }

    assert_response :unprocessable_content
    assert_equal [ children(:sam) ], entries(:painting).reload.children
  end

  test "editing an entry" do
    sign_in_as users(:bob)

    patch entry_path(entries(:painting)), params: { entry: { notes: entries(:moon).notes, minutes: "" } }

    assert_redirected_to entries_path
    assert_equal entries(:moon).notes, entries(:painting).reload.notes
    assert_nil entries(:painting).minutes
  end

  test "removing a photo from an entry" do
    entry = entries(:painting)
    entry.photos.attach(io: file_fixture("photo.jpg").open, filename: "kept.jpg")
    entry.photos.attach(io: file_fixture("photo.jpg").open, filename: "removed.jpg")
    kept = entry.photos.find { it.filename.to_s == "kept.jpg" }
    sign_in_as users(:alice)

    patch entry_path(entry), params: { entry: { photos: [ kept.signed_id, "" ] } }

    assert_redirected_to entries_path
    assert_equal [ kept.blob ], entry.reload.photos.map(&:blob)
  end

  test "deleting an entry" do
    sign_in_as users(:bob)

    assert_difference -> { families(:oaks).entries.count }, -1 do
      delete entry_path(entries(:painting))
    end

    assert_redirected_to entries_path
  end

  test "other families' entries are out of reach" do
    sign_in_as users(:alice)

    get edit_entry_path(entries(:den))
    assert_response :not_found

    patch entry_path(entries(:den)), params: { entry: { notes: entries(:painting).notes } }
    assert_response :not_found

    delete entry_path(entries(:den))
    assert_response :not_found
    assert Entry.exists?(entries(:den).id)
  end

  test "family members can see an entry's photos" do
    entries(:painting).photos.attach(io: file_fixture("photo.jpg").open, filename: "photo.jpg")
    photo = entries(:painting).photos.first
    sign_in_as users(:bob)

    get entry_photo_path(entries(:painting), photo, size: :thumbnail)

    assert_response :success
    assert_equal Mime[:webp], response.media_type
    assert response.cache_control[:private]
  end

  test "photos are private to the family" do
    entries(:painting).photos.attach(io: file_fixture("photo.jpg").open, filename: "photo.jpg")
    photo = entries(:painting).photos.first

    get entry_photo_path(entries(:painting), photo)
    assert_redirected_to new_session_path

    sign_in_as users(:carol)
    get entry_photo_path(entries(:painting), photo)
    assert_response :not_found
  end

  test "Active Storage's public URLs are switched off" do
    entries(:painting).photos.attach(io: file_fixture("photo.jpg").open, filename: "photo.jpg")
    blob = entries(:painting).photos.first.blob

    get "/rails/active_storage/blobs/redirect/#{blob.signed_id}/#{blob.filename}"

    assert_response :not_found
  end
end
