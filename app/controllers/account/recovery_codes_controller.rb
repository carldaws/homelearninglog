class Account::RecoveryCodesController < ApplicationController
  before_action :set_user

  def new
  end

  def create
    @user.assign_attributes(params.expect(user: [ :current_password ]))

    if @user.save(context: :recovery_code_renewal)
      redirect_to recovery_code_path, flash: { recovery_code: @user.recovery_code, continue_to: account_url }
    else
      render :new, status: :unprocessable_content
    end
  end

  private
    def set_user
      @user = Current.user
    end
end
