class Families::MembershipsController < ApplicationController
  include FamilyScoped

  before_action :set_membership

  def destroy
    if @membership.destroy
      redirect_to (@membership.user == Current.user ? new_family_path : family_path),
        notice: t(".removed", name: @membership.user.name), status: :see_other
    else
      redirect_to family_path, alert: @membership.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_membership
      @membership = Current.family.memberships.find(params[:id])
    end
end
