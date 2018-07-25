class HhApplicant < ActiveRecord::Base
  unloadable

  serialize :resume, Hash
end
