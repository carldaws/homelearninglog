class JoinsController < ApplicationController
  allow_unauthenticated_access only: :show
  rate_limit to: 30, within: 10.minutes, with: -> { redirect_to root_path, alert: t("joins.rate_limited") }
  before_action :set_family
  before_action :remember_invitation, only: :show, unless: :authenticated?

  def show
  end

  def create
    membership = @family.join(Current.user)

    if membership.persisted?
      redirect_to entries_path, notice: t(".joined", family: @family.name)
    else
      redirect_to join_path(params[:token]), alert: membership.errors.full_messages.to_sentence
    end
  end

  private
    def set_family
      @family = Family.find_by_token_for(:invitation, params[:token])
      render :expired, status: :not_found if @family.nil?
    end

    def remember_invitation
      session[:return_to_after_authenticating] = request.url
    end
end
