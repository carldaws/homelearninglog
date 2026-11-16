class Entries::PhotosController < ApplicationController
  include ChildScoped, PhotoStreaming

  before_action :set_photo

  def show
    stream @photo, params[:size] == "thumbnail" ? :thumbnail : :large
  end

  private
    def set_photo
      @photo = @child.entries.find(params[:entry_id]).photos.find(params[:id])
    end
end
