class Ideas::SetAsidesController < ApplicationController
  include IdeaScoped

  def create
    @idea.set_aside
    redirect_back_or_to @child
  end
end
