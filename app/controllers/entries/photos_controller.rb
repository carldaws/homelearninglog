class Entries::PhotosController < ApplicationController
  include FamilyScoped, PhotoStreaming

  before_action :set_photo

  def show
    stream @photo, params[:size] == "thumbnail" ? :thumbnail : :large
  end

  private
    def set_photo
      @photo = Current.family.entries.find(params[:entry_id]).photos.find(params[:id])
    end
end
