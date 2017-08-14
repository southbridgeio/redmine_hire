namespace :redmine_hire do
  desc 'Run sync process with hh api'
  task hh_api_sync: :environment do
    Hh::ApiService.new.execute
  end

  desc 'Rollback sync and remove all data'
  task hh_api_rollback: :environment do
    Hh::ApiService.new.rollback!
  end
end
