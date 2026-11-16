class KidsMenusController < ApplicationController
  include KidsModeScoped

  def show
    @activities = Current.family.activities.for_children.alphabetically.with_attached_picture
  end
end
