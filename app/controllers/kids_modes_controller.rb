class KidsModesController < ApplicationController
  include FamilyScoped

  allow_in_kids_mode only: :destroy
  before_action :require_children, only: %i[ new create ]
  rate_limit to: 10, within: 15.minutes, only: :destroy, with: -> { redirect_to kids_menu_path }

  def new
  end

  def create
    start_kids_mode Current.family.children.find(params.expect(:child_id))
    redirect_to kids_menu_path
  end

  def destroy
    if Current.user.authenticate_password(params.expect(:password)).present?
      stop_kids_mode
      redirect_to entries_path, status: :see_other
    else
      redirect_to kids_menu_path, status: :see_other
    end
  end
end
