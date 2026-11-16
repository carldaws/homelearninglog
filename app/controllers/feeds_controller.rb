class FeedsController < ApplicationController
  allow_unauthenticated_access

  def show
    render plain: CalendarFeed.new(Family.find_by!(calendar_token: params[:token])).to_ics, content_type: Mime[:ics]
  end
end
