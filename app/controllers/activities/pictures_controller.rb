class Activities::PicturesController < ApplicationController
  include FamilyScoped, PhotoStreaming

  allow_in_kids_mode

  def show
    stream picture, :tile
  end

  private
    def picture
      ActiveStorage::Attachment.find_by!(id: params[:id], name: "picture", record: Current.family.activities.find(params[:activity_id]))
    end
end
