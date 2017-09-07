module IssuePatch

  def self.included(base)
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      enum hiring_status: [:not_status, :refusal]
    end
  end
end

Issue.send(:include, IssuePatch)
