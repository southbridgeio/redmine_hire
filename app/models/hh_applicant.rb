class HhApplicant < ActiveRecord::Base
  unloadable

  serialize :resume
end
