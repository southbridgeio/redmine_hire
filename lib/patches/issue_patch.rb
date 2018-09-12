module IssuePatch
  def self.included(base)
    base.class_eval do
      has_one :hh_response
    end
  end
end

Issue.send(:include, IssuePatch)
