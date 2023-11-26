include ActionView::Helpers::UrlHelper

class Job < ActiveRecord::Base
  validates :starts_on,
            :ends_on,
            :name,
            presence: true

  belongs_to :project
  has_many :time_entries, dependent: :restrict_with_error
  has_many :time_budgets, dependent: :restrict_with_error
  accepts_nested_attributes_for :time_budgets, allow_destroy: true

  scope :project, ->(project) { where(project_id: project.id) }
  scope :project_or_parent, ->(project) { where(project_id: [project.id, project.parent&.id]) }

  def with_all_time_budgets
    time_budgets.build(job_id: id, activity_id: nil) unless time_budgets.where(activity_id: nil).exists?
    TimeEntryActivity.where.not(id: time_budgets.pluck(:activity_id)).each do |activity|
      time_budgets.build(job_id: id, activity_id: activity.id)
    end
    self
  end

  def missing_time_budgets
    budgets = []
    new_activities.collect { |activity| budgets << TimeBudget.new(job_id: id, activity_id: activity.id) }
  end

  def total_time_budget
    return 0 if time_budgets.empty?

    time_budgets.sum(&:hours)
  end

  def time_budget_for(activity)
    time_budgets.where(activity_id: activity.id).hours || 0
  end

  def total_time_logged
    TimeEntry.where(job_id: id)
             .sum(:hours)
  end

  def total_time_logged_for(activity)
    TimeEntry.where(job_id: id, activity_id: activity&.id)
             .sum(:hours)
  end

  def to_s
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    ActionController::Base.helpers.link_to name, ActionController::Base.helpers.project_job_path(project, self)
  end
end
