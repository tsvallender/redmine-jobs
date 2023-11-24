class TimeBudget < ActiveRecord::Base
  validates :hours,
            presence: true

  validates :activity_id,
            inclusion: { in: TimeEntryActivity.pluck(:id) },
            allow_nil: true

  validates_uniqueness_of :job_id, scope: :activity_id, message: "Only one time budget can exist for each activity type"

  belongs_to :job
  belongs_to :activity, class_name: "TimeEntryActivity"
end
