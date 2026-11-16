class Activities::EntriesController < ApplicationController
  include FamilyScoped

  before_action :require_children

  def new
    @entry = Current.family.activities.find(params[:activity_id]).draft_entry
    render "entries/new"
  end
end
