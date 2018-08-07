class HhVacancy < ActiveRecord::Base
  unloadable

  serialize :info
end
