class Ideas::EntriesController < ApplicationController
  include IdeaScoped

  def new
    @entry = @child.draft_entry(suggestion: @idea)
    render "entries/new"
  end
end
