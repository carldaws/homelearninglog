class Pursuits::FinishesController < ApplicationController
  include FamilyScoped

  before_action :set_pursuit

  def create
    @pursuit.finish
    redirect_to @pursuit
  end

  def destroy
    @pursuit.pick_up
    redirect_to @pursuit, status: :see_other
  end

  private
    def set_pursuit
      @pursuit = Current.family.pursuits.find(params[:pursuit_id])
    end
end
