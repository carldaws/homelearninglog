class AccountsController < ApplicationController
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    @user.assign_attributes(account_params)

    if @user.save(context: :account_change)
      redirect_to account_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @user.assign_attributes(params.expect(user: [ :current_password ]))

    if @user.valid?(:account_deletion)
      terminate_session
      @user.destroy!
      redirect_to root_path, status: :see_other
    else
      render "account/deletions/new", status: :unprocessable_content
    end
  end

  private
    def set_user
      @user = Current.user
    end

    def account_params
      params.expect(user: [ :name, :email_address, :current_password ])
    end
end
