class Ideas::EntriesController < ApplicationController
  include IdeaScoped

  def new
    @entry = @child.draft_entry(followed_idea: @idea)
    render "entries/new"
  end
end
