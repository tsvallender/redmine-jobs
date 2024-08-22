class Job < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper
  include Redmine::SafeAttributes

  validates :starts_on,
            :ends_on,
            :name,
            presence: true

  belongs_to :project
  belongs_to :category, class_name: "JobCategory"

  has_many :time_entries, dependent: :restrict_with_error
  has_many :time_budgets, dependent: :destroy
  has_many :journals, as: :journalized, dependent: :destroy, inverse_of: :journalized
  delegate :notes, :notes=, to: :current_journal, allow_nil: true
  accepts_nested_attributes_for :time_budgets, allow_destroy: true

  acts_as_customizable
  acts_as_watchable
  acts_as_mentionable attributes: [ "description" ]

  scope :project_or_parent, ->(project) { where(project_id: [project&.id, project&.parent&.id]) }
  scope :active, -> { where(starts_on: ..Date.today, ends_on: Date.today..) }

  safe_attributes 'name', 'description'

  after_save :create_journal

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
    ActionController::Base.helpers.link_to name, ActionController::Base.helpers.job_path(self)
  end

  def init_journal(user, notes = "")
    @current_journal = Journal.new(journalized: self, user: user, notes: notes)
  end

  def current_journal
    @current_journal
  end

  def create_journal
    current_journal.save if current_journal
  end

  def journalized_attribute_names
    Job.column_names - %w(id created_at updated_at)
  end

  def notified_users
    []
  end

  def notes_addable?(user = User.current)
    #user_tracker_permission?(user, :add_job_notes)
    true
  end

  # Used for journal actions (edit, quote)
  def visible_journals_with_index
    result = journals.
      preload(:details).
      preload(:user => :email_address).
      reorder(:created_on, :id).to_a

    result.each_with_index {|j, i| j.indice = i + 1}
    result
  end

  # tracker and subject are used to make Job quack like an issue so the diff view
  # built into Redmine will work
  def tracker
    OpenStruct.new(
      name: name,
      to_s: "Job",
    )
  end

  def subject
    name
  end

  def self.fields_for_order_statement
    "jobs.name"
  end

  def self.default_for(time_entry)
    projects = [time_entry.project, time_entry.project.parent]
    jobs = Job.where(project: projects).active
    support = jobs.where(category: JobCategory.support).first
    retainer = jobs.where(category: JobCategory.retainer).first
    sprints = jobs.where(category: JobCategory.sprints).first
    priority_list = [sprints, retainer, support].compact

    return jobs.first if priority_list.empty?

    return support if time_entry.activity.name == "Support"

    return priority_list.first if time_entry.issue.blank?

    return support if time_entry.issue.tracker.name == "Support"

    priority_list.first
  end
end
