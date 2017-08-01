ActionDispatch::Callbacks.to_prepare do
  paths = '/app/services/*.rb'
  Dir.glob(File.dirname(__FILE__) + paths).each do |file|
    require_dependency file
  end
end

Redmine::Plugin.register :redmine_hire do
  name 'Redmine Hire plugin'
  author 'Southbridge'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'https://github.com/centosadmin'
end
