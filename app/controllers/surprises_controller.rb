class SurprisesController < ApplicationController
  include KidsModeScoped

  def create
    redirect_to choosing_child.choose(Current.family.activities.for_children.sample || raise(ActiveRecord::RecordNotFound))
  end
end
