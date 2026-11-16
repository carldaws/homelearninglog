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
      authenticated? && Current.session.kids_mode?
    end

    def choosing_child
      Current.session.choosing_child
    end

    def keep_to_kids_menu
      redirect_to kids_menu_path
    end

    def start_kids_mode(child)
      Current.session.update!(choosing_child: child)
    end

    def stop_kids_mode
      Current.session.update!(choosing_child: nil)
    end
end
