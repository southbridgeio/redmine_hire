namespace :redmine_hire do
  desc 'Run sync process with hh api'
  task hh_api_sync: :environment do
    Hh::ApiService.new.execute
  end
end
