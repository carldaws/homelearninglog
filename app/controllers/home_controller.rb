class HomeController < ApplicationController
  allow_unauthenticated_access

  def show
    if authenticated?
      redirect_to Current.user.children.alphabetically.first || new_child_path
    end
  end
end
