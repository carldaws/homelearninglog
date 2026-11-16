class Calendars::SubscriptionsController < ApplicationController
  include ChildScoped

  before_action :no_store

  def show
  end

  def update
    @child.regenerate_calendar_token
    redirect_to child_calendar_subscription_path(@child), status: :see_other
  end
end
