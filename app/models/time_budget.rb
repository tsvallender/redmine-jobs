class TimeBudget < ActiveRecord::Base
  validates :hours,
            presence: true

  validates :activity_id,
            inclusion: { in: TimeEntryActivity.pluck(:id) }

  belongs_to :job
  belongs_to :activity, class_name: "TimeEntryActivity"

end
