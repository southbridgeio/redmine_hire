class RedmineHireController < ApplicationController
  unloadable

  def refusal_response
    @issue = Issue.find(params[:id])
    Hh::ApiService.new.send_refusal(@issue.id)
    redirect_to @issue
  end
end
