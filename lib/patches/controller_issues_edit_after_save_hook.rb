class ControllerIssuesEditAfterSaveHook < Redmine::Hook::ViewListener

  def controller_issues_edit_after_save(context={})
    if context.dig(:params, :issue, :auto_refusal)
      Hh::ApiService.new.send_refusal(params[:id])
    end
  end

end
