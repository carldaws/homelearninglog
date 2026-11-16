class Entries::PhotosController < ApplicationController
  include FamilyScoped
  include ActiveStorage::Streaming

  before_action :set_photo

  def show
    http_cache_forever(public: false) do
      send_blob_stream @photo.variant(size).processed.image, disposition: :inline
    end
  end

  private
    def set_photo
      @photo = Current.family.entries.find(params[:entry_id]).photos.find(params[:id])
    end

    def size
      params[:size] == "thumbnail" ? :thumbnail : :large
    end
end
