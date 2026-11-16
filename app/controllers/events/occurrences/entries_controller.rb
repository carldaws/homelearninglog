class Events::Occurrences::EntriesController < ApplicationController
  include OccurrenceScoped

  before_action :require_children

  def new
    @entry = @occurrence.draft_entry
    render "entries/new"
  end
end
