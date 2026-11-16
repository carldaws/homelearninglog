class Families::Memberships::SignInLinksController < ApplicationController
  include FamilyScoped

  before_action :set_membership
  before_action :no_store

  def show
    @sign_in_link = edit_password_url(@membership.user.generate_token_for(:sign_in_link))
  end

  private
    def set_membership
      @membership = Current.family.memberships.find(params[:membership_id])
    end
end
