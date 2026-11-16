class HomeController < ApplicationController
  allow_unauthenticated_access
  before_action :redirect_when_signed_in

  def show
  end
end
