# frozen_string_literal: true

# Add jobs
module TimeReportHelperPatch
  extend ActiveSupport::Concern

  included do
    include InstanceMethods

    alias_method :load_available_criteria_without_jobs, :load_available_criteria
    alias_method :load_available_criteria, :load_available_criteria_with_jobs
  end

  module InstanceMethods
    def load_available_criteria_with_jobs
      @available_criteria = load_available_criteria_without_jobs
      @available_criteria['job'] = {
        sql: "#{TimeEntry.table_name}.job_id",
        klass: Job,
        label: 'Job'
      }
      @available_criteria
    end
  end
end
