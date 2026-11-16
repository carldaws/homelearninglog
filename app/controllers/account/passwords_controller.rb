class Account::PasswordsController < ApplicationController
  before_action :set_user

  def edit
  end

  def update
    @user.assign_attributes(params.expect(user: [ :current_password, :password ]))

    if @user.save(context: :password_change)
      start_new_session_for @user
      redirect_to account_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def set_user
      @user = Current.user
    end
end
