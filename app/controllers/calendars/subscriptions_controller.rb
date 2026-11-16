class Calendars::SubscriptionsController < ApplicationController
  include FamilyScoped

  before_action :no_store

  def show
  end

  def update
    Current.family.regenerate_calendar_token
    redirect_to calendar_subscription_path, status: :see_other
  end
end
