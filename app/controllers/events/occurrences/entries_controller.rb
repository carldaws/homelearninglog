class Events::Occurrences::EntriesController < ApplicationController
  include OccurrenceScoped

  def new
    @entry = @occurrence.draft_entry
    render "entries/new"
  end
end
