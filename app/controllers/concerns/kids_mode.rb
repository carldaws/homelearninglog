module KidsMode
  extend ActiveSupport::Concern

  included do
    before_action :keep_to_kids_menu, if: :kids_mode?
    helper_method :kids_mode?, :choosing_child
  end

  class_methods do
    def allow_in_kids_mode(**options)
      skip_before_action :keep_to_kids_menu, **options
    end
  end

  private
    def kids_mode?
      session[:choosing_child_id].present?
    end

    def choosing_child
      @choosing_child ||= Current.family.children.find(session[:choosing_child_id])
    end

    def keep_to_kids_menu
      redirect_to kids_menu_path
    end

    def require_kids_mode
      redirect_to new_kids_mode_path unless kids_mode?
    end

    def start_kids_mode(child)
      session[:choosing_child_id] = child.id
    end

    def stop_kids_mode
      session.delete(:choosing_child_id)
    end
end
