class KidsMenusController < ApplicationController
  include FamilyScoped

  allow_in_kids_mode
  before_action :require_kids_mode

  def show
    @activities = Current.family.activities.for_children.alphabetically.with_attached_picture
  end
end
