module ApplicationHelper
  def tab_to(name, path, controllers:)
    link_to name, path, class: "tab", aria: { current: ("page" if controllers.include?(controller_path)) }
  end
end
