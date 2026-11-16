module PhotoStreaming
  extend ActiveSupport::Concern
  include ActiveStorage::Streaming

  private
    def stream(photo, size)
      http_cache_forever(public: false) do
        send_blob_stream photo.variant(size).processed.image, disposition: :inline
      end
    end
end
