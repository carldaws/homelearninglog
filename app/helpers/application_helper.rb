module ApplicationHelper
  def tab_to(name, path, controllers:)
    link_to name, path, class: "tab", aria: { current: ("page" if controllers.intersect?([ controller_path, "#{controller_path}##{action_name}" ])) }
  end
end
