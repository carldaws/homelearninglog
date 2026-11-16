class Families::InvitationsController < ApplicationController
  include FamilyScoped

  before_action :no_store

  def show
    @invitation_link = join_url(Current.family.generate_token_for(:invitation))
  end
end
