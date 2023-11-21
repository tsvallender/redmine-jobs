Redmine::Plugin.register :jobs do
  name 'Redmine Jobs plugin'
  author 'T S Vallender'
  description 'Manage jobs in Redmine'
  version '0.0.1'
  url 'http://tsvallender.co.uk'
  author_url 'http://tsvallender.co.uk'

  permission :jobs, { jobs: [:index, :show, :new, :create, :edit, :update, :destroy] }, public: true
  menu :project_menu, :jobs, { controller: 'jobs', action: 'index' }, caption: 'Jobs', after: :issues, param: :project_id

  TimeEntry.safe_attributes 'job_id'
end
