class Families::MembershipsController < ApplicationController
  include FamilyScoped

  before_action :set_membership

  def destroy
    if @membership.destroy
      if @membership.user == Current.user
        redirect_to new_family_path, notice: t(".left", family: @membership.family.name), status: :see_other
      else
        redirect_to family_path, notice: t(".removed", name: @membership.user.name), status: :see_other
      end
    else
      redirect_to family_path, alert: @membership.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_membership
      @membership = Current.family.memberships.find(params[:id])
    end
end
