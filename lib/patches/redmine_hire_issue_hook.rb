class RedmineHireIssueHook < Redmine::Hook::ViewListener
  render_on :view_issues_edit_notes_bottom, partial: 'redmine_hire/auto_refusal_checkbox'
  render_on :view_issues_show_details_bottom, partial: 'redmine_hire/auto_refusal_link'
  render_on :view_issues_show_details_bottom, partial: 'redmine_hire/issue_description'
end
