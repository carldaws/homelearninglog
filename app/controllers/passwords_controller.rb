class PasswordsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 15.minutes, only: :update, with: -> { redirect_to new_session_path, alert: t(".rate_limited") }
  before_action :set_user
  before_action :no_store

  def edit
  end

  def update
    @user.assign_attributes(params.expect(user: [ :password ]))

    if @user.save(context: :password_change)
      start_new_session_for @user
      redirect_to after_authentication_url
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def set_user
      @user = User.find_by_token_for(:sign_in_link, params[:token])
      render :expired, status: :not_found if @user.nil?
    end
end
