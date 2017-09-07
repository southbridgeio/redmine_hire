class AutoRefusalHook < Redmine::Hook::ViewListener
  render_on :view_issues_edit_notes_bottom, partial: 'redmine_hire/auto_refusal_checkbox'

  render_on :view_issues_context_menu_start, partial: 'redmine_hire/auto_refusal_link'
end
