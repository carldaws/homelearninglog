class Ideas::SetAsidesController < ApplicationController
  include IdeaScoped

  def create
    @idea.set_aside
    redirect_back_or_to @child
  end

  def destroy
    @idea.bring_back
    redirect_back_or_to @child, status: :see_other
  end
end
