class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :redirect_when_signed_in
  before_action :no_store
  rate_limit to: 10, within: 15.minutes, only: :create, name: "by-ip", with: -> { reject_as_rate_limited }
  rate_limit to: 5, within: 1.hour, only: :create, name: "by-email-address", by: -> { attempted_email_address },
    with: -> { reject_as_rate_limited }
  before_action :set_user, only: :create

  def new
  end

  def create
    @user.password = params.expect(:password)

    if @user.save(context: :password_reset)
      start_new_session_for @user
      redirect_to recovery_code_path, flash: { recovery_code: @user.recovery_code, continue_to: after_authentication_url }
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  private
    def set_user
      @user = User.authenticate_by_recovery_code(email_address: attempted_email_address, recovery_code: params.expect(:recovery_code))

      if @user.nil?
        flash.now[:alert] = t(".invalid")
        render :new, status: :unprocessable_content
      end
    end

    def attempted_email_address
      User.normalize_value_for(:email_address, params.expect(:email_address))
    end

    def reject_as_rate_limited
      redirect_to new_password_path, alert: t(".rate_limited")
    end
end
