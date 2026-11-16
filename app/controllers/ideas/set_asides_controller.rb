class Ideas::SetAsidesController < ApplicationController
  include IdeaScoped

  def create
    @idea.set_aside
    redirect_to @child
  end
end
