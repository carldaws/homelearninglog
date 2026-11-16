module KidsModeScoped
  extend ActiveSupport::Concern
  include FamilyScoped

  included do
    allow_in_kids_mode
    before_action :require_kids_mode
  end

  private
    def require_kids_mode
      redirect_to new_kids_mode_path unless kids_mode?
    end
end
