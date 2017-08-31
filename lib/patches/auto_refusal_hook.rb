class AutoRefusalHook < Redmine::Hook::ViewListener
  render_on :view_issues_edit_notes_bottom, partial: 'redmine_hire/auto_refusal_checkbox'
end
