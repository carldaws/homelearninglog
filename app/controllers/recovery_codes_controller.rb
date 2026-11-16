class RecoveryCodesController < ApplicationController
  before_action :no_store

  def show
    @recovery_code = flash[:recovery_code]
    redirect_to root_path if @recovery_code.blank?
  end
end
