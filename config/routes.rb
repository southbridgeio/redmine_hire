Rails.application.routes.draw do
  post 'issue/:id/refusal_response', :to => 'redmine_hire#refusal_response'
end
