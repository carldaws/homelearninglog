class Calendars::SubscriptionsController < ApplicationController
  include ChildScoped

  before_action :set_access
  before_action :no_store

  def show
  end

  def update
    @access.regenerate_calendar_token
    redirect_to child_calendar_subscription_path(@child), status: :see_other
  end

  private
    def set_access
      @access = @child.accesses.find_by!(user: Current.user)
    end
end
