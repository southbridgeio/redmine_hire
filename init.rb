ActionDispatch::Callbacks.to_prepare do
  paths = '/lib/**/*.rb'
  Dir.glob(File.dirname(__FILE__) + paths).each do |file|
    require_dependency file
  end
end

Redmine::Plugin.register :redmine_hire do
  name 'Redmine Hire plugin'
  author 'Southbridge'
  description 'Plugin to work with the hire responses'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'https://github.com/centosadmin'

  settings :default => {'hh_access_token' => '', 'hh_employer_id' => ''}, :partial => 'settings/redmine_hire_settings'
end
