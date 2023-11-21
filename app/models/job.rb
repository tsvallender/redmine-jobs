class Job < ActiveRecord::Base
  validates :starts_on,
            :ends_on,
            :name,
            presence: true

  belongs_to :project

  scope :project, ->(project) { where(project_id: project.id) }

  def time_logged
    42
  end
end
