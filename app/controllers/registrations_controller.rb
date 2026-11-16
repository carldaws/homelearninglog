class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  before_action :redirect_when_signed_in
  rate_limit to: 10, within: 15.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: t(".rate_limited") }

  def new
    @user = User.new
  end

  def create
    @user = User.new(params.expect(user: [ :name, :email_address, :password ]))

    if @user.save
      start_new_session_for @user
      redirect_to recovery_code_path, flash: { recovery_code: @user.recovery_code, continue_to: after_authentication_url }
    else
      render :new, status: :unprocessable_content
    end
  end
end
