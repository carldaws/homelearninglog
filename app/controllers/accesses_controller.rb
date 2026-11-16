class AccessesController < ApplicationController
  include ChildScoped

  before_action :set_access

  def destroy
    if @access.destroy
      redirect_to (@access.user == Current.user ? root_path : edit_child_path(@child)), status: :see_other
    else
      redirect_to edit_child_path(@child), alert: @access.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_access
      @access = @child.accesses.find(params[:id])
    end
end
