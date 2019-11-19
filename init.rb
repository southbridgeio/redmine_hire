ActionDispatch::Callbacks.to_prepare do
  paths = ['/lib/**/*.rb', '/app/worker/*.rb']
  paths.each do |path|
    Dir.glob(File.dirname(__FILE__) + path).each do |file|
      require_dependency file
    end
  end
end

Redmine::Plugin.register :redmine_hire do
  name 'Redmine Hire plugin'
  author 'Southbridge'
  description 'Plugin to work with the hh.ru api service'
  version '0.0.1'
  url 'https://github.com/southbridgeio/redmine_hire'
  author_url 'https://github.com/southbridgeio'

  settings :default => {
    'client_id' => '',
    'client_secret' => '',
    'project_name' => '',
    'issue_status' => '',
    'issue_tracker' => '',
    'issue_author' => '',
    'hh_api_sync_cron' => '',
    'access_token' => '',
    'refresh_token' => ''
  }, :partial => 'settings/redmine_hire_settings'
end
