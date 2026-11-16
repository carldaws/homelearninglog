module FamilyScoped
  extend ActiveSupport::Concern

  included do
    before_action :require_family
  end

  private
    def require_family
      redirect_to new_family_path if Current.family.nil?
    end
end
