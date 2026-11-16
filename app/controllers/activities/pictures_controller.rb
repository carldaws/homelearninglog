class Activities::PicturesController < ApplicationController
  include FamilyScoped, PhotoStreaming

  allow_in_kids_mode

  def show
    stream picture, :tile
  end

  private
    def picture
      Current.family.activities.find(params[:activity_id]).picture.presence || raise(ActiveRecord::RecordNotFound)
    end
end
