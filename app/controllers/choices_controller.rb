class ChoicesController < ApplicationController
  include FamilyScoped

  allow_in_kids_mode
  before_action :require_kids_mode

  def create
    choice = choosing_child.choose(Current.family.activities.for_children.find(params.expect(:activity_id)))
    redirect_to choice
  end

  def show
    @choice = Choice.where(child: Current.family.children).find(params[:id])
  end
end
