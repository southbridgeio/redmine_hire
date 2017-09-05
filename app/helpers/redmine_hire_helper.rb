module RedmineHireHelper

  def exp_in_monthes(start, finish)
    finish = finish || Date.current
    (finish.to_date - start.to_date).to_i/30
  end

end
