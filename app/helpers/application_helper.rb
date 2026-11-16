module ApplicationHelper
  def tab_to(name, path, sections:)
    link_to name, path, class: "tab", aria: { current: ("page" if sections.any? { controller_path.start_with?(it) }) }
  end
end
