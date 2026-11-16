class ChoicesController < ApplicationController
  include KidsModeScoped

  def create
    choice = choosing_child.choose(Current.family.activities.for_children.find(params.expect(:activity_id)))
    redirect_to choice
  end

  def show
    @choice = Current.family.choices.find(params[:id])
  end
end
