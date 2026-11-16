class JoinsController < ApplicationController
  allow_unauthenticated_access only: :show
  before_action :set_invitation
  before_action :remember_invitation, only: :show, unless: :authenticated?

  def show
  end

  def create
    @invitation.accept(Current.user)
    redirect_to root_path
  end

  private
    def set_invitation
      @invitation = Invitation.unexpired.find_by(token: params[:token])
      render :expired, status: :not_found if @invitation.nil? || @invitation.offered_children.none?
    end

    def remember_invitation
      session[:return_to_after_authenticating] = request.url
    end
end
