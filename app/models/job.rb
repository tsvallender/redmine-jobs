include ActionView::Helpers::UrlHelper

class Job < ActiveRecord::Base
  validates :starts_on,
            :ends_on,
            :name,
            presence: true

  belongs_to :project
  has_many :time_entries

  scope :project, ->(project) { where(project_id: project.id) }

  def total_time_logged
    TimeEntry.where(job_id: id)
             .sum(:hours)
  end

  def total_time_logged_for(activity)
    TimeEntry.where(job_id: id, activity_id: activity.id)
             .sum(:hours)
  end

  def to_s
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    ActionController::Base.helpers.link_to name, ActionController::Base.helpers.job_path(self, project_id: project.id)
  end
end
