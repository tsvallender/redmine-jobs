include ActionView::Helpers::UrlHelper

class Job < ActiveRecord::Base
  validates :starts_on,
            :ends_on,
            :name,
            presence: true

  belongs_to :project
  belongs_to :category, class_name: "JobCategory"

  has_many :time_entries, dependent: :restrict_with_error
  has_many :time_budgets, dependent: :destroy
  accepts_nested_attributes_for :time_budgets, allow_destroy: true

  scope :project_or_parent, ->(project) { where(project_id: [project.id, project.parent&.id]) }
  scope :active, -> { where(starts_on: ..Date.today, ends_on: Date.today..) }

  def with_all_time_budgets
    time_budgets.build(job_id: id, category_id: nil) unless time_budgets.where(category_id: nil).exists?
    TimeBudgetCategory.where.not(id: time_budgets.pluck(:category_id)).each do |category|
      time_budgets.build(job_id: id, category_id: category.id)
    end
    self
  end

  def missing_time_budgets
    budgets = []
    new_activities.collect { |category| budgets << TimeBudget.new(job_id: id, category_id: category.id) }
  end

  def total_time_budget
    return 0 if time_budgets.empty?

    time_budgets.sum(&:hours)
  end

  def total_time_logged
    TimeEntry.where(job_id: id)
             .sum(:hours)
  end

  def done_ratio
    return 0 if total_time_budget.zero?

    (total_time_logged / total_time_budget * 100).to_i
  end

  def to_s
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    ActionController::Base.helpers.link_to name, ActionController::Base.helpers.project_job_path(project, self)
  end
end
