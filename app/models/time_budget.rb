class TimeBudget < ActiveRecord::Base
  validates :hours,
            presence: true

  validates :category_id,
            inclusion: { in: TimeBudgetCategory.pluck(:id) },
            allow_nil: true

  validates_uniqueness_of :job_id, scope: :category_id, message: "Only one time budget can exist for each category"

  belongs_to :job
  belongs_to :category, class_name: "TimeBudgetCategory"

  def done_ratio
    return 0 if hours.zero?

    (total_time_logged / hours * 100).to_i
  end

  def total_time_logged
    TimeEntry.joins(:user)
             .where(
               job_id: job_id,
               users: { time_budget_category_id: category_id }
             ).sum(:hours)
  end
end
