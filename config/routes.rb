Rails.application.routes.draw do
  post 'issue/:id/refusal_response', :to => 'redmine_hire#refusal_response'
  get '/redmine_hire/init_sidekiq_jobs', :to => 'redmine_hire#init_sidekiq_jobs'
end
