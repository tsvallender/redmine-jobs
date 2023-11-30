class TimeBudget < ActiveRecord::Base
  validates :hours,
            presence: true

  validates :category_id,
            inclusion: { in: TimeBudgetCategory.pluck(:id) },
            allow_nil: true

  validates_uniqueness_of :job_id, scope: :category_id, message: "Only one time budget can exist for each category"

  belongs_to :job
  belongs_to :category, class_name: "TimeBudgetCategory"
end
