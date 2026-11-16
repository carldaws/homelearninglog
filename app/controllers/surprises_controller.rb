class SurprisesController < ApplicationController
  include FamilyScoped

  allow_in_kids_mode
  before_action :require_kids_mode

  def create
    redirect_to choosing_child.choose(Current.family.activities.for_children.sample || raise(ActiveRecord::RecordNotFound))
  end
end
