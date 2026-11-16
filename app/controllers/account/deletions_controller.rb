class Account::DeletionsController < ApplicationController
  before_action :set_user

  def new
  end

  private
    def set_user
      @user = Current.user
    end
end
