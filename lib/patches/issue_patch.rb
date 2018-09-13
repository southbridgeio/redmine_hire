module IssuePatch
  def self.included(base)
    base.class_eval do
      enum hiring_status: [:not_status, :refusal]

      has_one :hh_response
    end
  end
end

Issue.send(:include, IssuePatch)
