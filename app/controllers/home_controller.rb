class HomeController < ApplicationController
  allow_unauthenticated_access

  def show
    if authenticated?
      redirect_to remembered_child || Current.user.children.alphabetically.first || new_child_path
    end
  end

  private
    def remembered_child
      Current.user.children.find_by(id: cookies.signed[:child_id])
    end
end
