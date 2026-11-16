require "test_helper"
require "vips"

class EntryTest < ActiveSupport::TestCase
  setup do
    @entry = families(:oaks).entries.build(author: users(:alice), happened_on: Date.current, children: [ children(:sam) ])
  end

  test "an entry needs notes or a photo" do
    assert_not @entry.valid?
    assert @entry.errors.of_kind?(:base, :empty)

    @entry.photos.attach(io: file_fixture("photo.jpg").open, filename: "photo.jpg")
    assert @entry.valid?
  end

  test "an entry is about at least one child" do
    @entry.assign_attributes(notes: entries(:painting).notes, child_ids: [])

    assert_not @entry.valid?
    assert @entry.errors.of_kind?(:children, :blank)
  end

  test "an entry can only be about the family's own children" do
    @entry.assign_attributes(notes: entries(:painting).notes, child_ids: [ children(:ivy).id, children(:wren).id ])

    assert_not @entry.valid?
    assert @entry.errors.of_kind?(:children, :outside_the_family)
  end

  test "an entry's event has to be the family's own" do
    @entry.assign_attributes(notes: entries(:painting).notes, event: events(:swimming))

    assert_not @entry.valid?
    assert @entry.errors.of_kind?(:event, :outside_the_family)
  end

  test "entries can't be in the future" do
    @entry.assign_attributes(notes: entries(:painting).notes, happened_on: Date.tomorrow)

    assert_not @entry.valid?
    assert @entry.errors.of_kind?(:happened_on, :less_than_or_equal_to)
  end

  test "time spent is optional but sensible" do
    @entry.notes = entries(:painting).notes

    @entry.minutes = nil
    assert @entry.valid?

    @entry.minutes = 0
    assert_not @entry.valid?

    @entry.minutes = 25.hours.in_minutes
    assert_not @entry.valid?
  end

  test "photos have to be photos" do
    @entry.photos.attach(io: file_fixture("notes.txt").open, filename: "notes.txt")

    assert_not @entry.valid?
    assert @entry.errors.of_kind?(:base, :not_a_photo)
  end

  test "photos are shown as WebP without their metadata" do
    @entry.photos.attach(io: file_fixture("photo.jpg").open, filename: "photo.jpg")
    @entry.save!

    original = @entry.photos.first
    thumbnail = original.variant(:thumbnail).processed.image

    assert exif?(original)
    assert_not exif?(thumbnail)
    assert_equal Mime[:webp], thumbnail.content_type
  end

  private
    def exif?(file)
      Vips::Image.new_from_buffer(file.download, "").get_fields.include?("exif-data")
    end
end
