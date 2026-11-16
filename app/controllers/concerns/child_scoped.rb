module ChildScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_child
  end

  private
    def set_child
      @child = Current.user.children.find(params[:child_id])
    end
end
