class Activities::EventsController < ApplicationController
  include FamilyScoped

  before_action :require_children

  def new
    @event = Current.family.activities.find(params[:activity_id]).draft_event
    render "events/new"
  end
end
