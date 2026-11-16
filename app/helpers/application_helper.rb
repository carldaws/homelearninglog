module ApplicationHelper
  def tab_to(name, path, section:)
    link_to name, path, class: "tab", aria: { current: ("page" if controller_path.start_with?(section)) }
  end
end
