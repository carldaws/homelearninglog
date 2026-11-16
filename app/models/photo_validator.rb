class PhotoValidator < ActiveModel::EachValidator
  CONTENT_TYPES = %w[ image/jpeg image/png image/webp image/gif image/heic image/heif ].freeze
  MAXIMUM_SIZE = 25.megabytes

  def validate_each(record, _attribute, attached)
    blobs = attached.respond_to?(:blobs) ? attached.blobs : [ attached.blob ].compact

    blobs.each do |blob|
      record.errors.add(:base, :not_a_photo, filename: blob.filename) unless blob.content_type.in?(CONTENT_TYPES)
      record.errors.add(:base, :photo_too_big, filename: blob.filename, size: MAXIMUM_SIZE.to_fs(:human_size)) if blob.byte_size > MAXIMUM_SIZE
    end
  end
end
