Redmine::Plugin.register :jobs do
  name 'Redmine Jobs plugin'
  author 'T S Vallender'
  description 'Manage jobs in Redmine'
  version '0.0.1'
  url 'http://tsvallender.co.uk'
  author_url 'http://tsvallender.co.uk'

  menu :project_menu, :jobs, { controller: 'jobs', action: 'index' }, caption: 'Jobs', after: :issues, param: :project_id

  TimeEntry.safe_attributes 'job_id'
  User.safe_attributes 'time_budget_category_id'

  Rails.application.config.before_initialize do
    Rails.logger.info "Patch Jobs"
    TimeEntryQuery.send(:include, TimeEntryQueryPatch)
    TimeEntry.send(:include, TimeEntryPatch)
    Project.send(:include, ProjectPatch)
    Redmine::Helpers::TimeReport.send(:include, TimeReportHelperPatch)
  end

  project_module :jobs do
    permission :jobs, { jobs: [:index, :show, :new, :create, :edit, :update, :destroy] }, public: false
  end
end
