namespace :redmine_hire do
  desc 'Run sync process for active vacancies with hh api'
  task hh_api_sync_active: :environment do
    Hh::ApiService.new.execute('active')
  end

  desc 'Run sync process for archived vacancies with hh api'
  task hh_api_sync_archived: :environment do
    Hh::ApiService.new.execute('archived')
  end

  desc 'Rollback sync and remove all sync data'
  task hh_api_rollback: :environment do
    Hh::ApiService.new.rollback!
  end
end
