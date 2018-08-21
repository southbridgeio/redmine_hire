module IssuePatch

  def self.included(base)
    base.class_eval do
      enum hiring_status: [:not_status, :refusal]
    end
  end
end

Issue.send(:include, IssuePatch)
