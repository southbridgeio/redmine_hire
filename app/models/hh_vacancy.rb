class HhVacancy < ActiveRecord::Base
  unloadable

  serialize :info, Hash
end
