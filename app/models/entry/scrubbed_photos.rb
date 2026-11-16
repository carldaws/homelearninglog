module Entry::ScrubbedPhotos
  extend ActiveSupport::Concern

  KEPT_FORMATS = { "image/png" => "png", "image/webp" => "webp", "image/gif" => "gif" }.freeze

  def photos=(attachables)
    super(Array(attachables).map { scrubbed(it) })
  end

  private
    def scrubbed(attachable)
      if attachable.respond_to?(:tempfile) && attachable.content_type.in?(PhotoValidator::CONTENT_TYPES)
        format = KEPT_FORMATS.fetch(attachable.content_type, "jpg")
        { io: ImageProcessing::Vips.source(attachable.tempfile.path).saver(strip: true).convert(format).call,
          filename: "#{File.basename(attachable.original_filename.to_s, ".*")}.#{format}", content_type: Marcel::MimeType.for(extension: format) }
      else
        attachable
      end
    rescue Vips::Error
      attachable
    end
end
