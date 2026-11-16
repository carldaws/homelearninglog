module FamilyScoped
  extend ActiveSupport::Concern

  included do
    before_action :require_family
  end

  private
    def require_family
      redirect_to new_family_path if Current.family.nil?
    end

    def require_children
      redirect_to new_family_child_path if Current.family.children.none?
    end
end
