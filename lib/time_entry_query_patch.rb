# frozen_string_literal: true

require_dependency 'time_entry_query'

# Here we add the jobs field so it shows in a time entry query as an available column.
module TimeEntryQueryPatch
  extend ActiveSupport::Concern

  included do
    include InstanceMethods

    alias_method :initialize_available_filters_without_jobs, :initialize_available_filters
    alias_method :initialize_available_filters, :initialize_available_filters_with_jobs

    alias_method :available_columns_without_jobs, :available_columns
    alias_method :available_columns, :available_columns_with_jobs

    alias_method :joins_for_order_statement_without_jobs, :joins_for_order_statement
    alias_method :joins_for_order_statement, :joins_for_order_statement_with_jobs
  end

  module InstanceMethods
    def initialize_available_filters_with_jobs
      initialize_available_filters_without_jobs
      initialize_issue_jobs_filter
    end

    def available_columns_with_jobs
      if @available_columns.nil?
        @available_columns = available_columns_without_jobs
        @available_columns << QueryColumn.new(:job, groupable: true, sortable: -> { Job.fields_for_order_statement })
      else
        available_columns_without_jobs
      end
      @available_columns
    end

    def initialize_issue_jobs_filter(position: nil)
      add_available_filter("job_id", order: position,
                                   type: :list_optional,
                                   values: jobs_list
                          )
    end

    def sql_for_issue_jobs_field(_field, operator, values)
      build_sql_for_jobs_field klass: Issue, operator: operator, values: values
    end

    def jobs_list
      Job.where(project: [project, project&.parent]).map do |job|
        [job.name, job.id.to_s]
      end
    end

    def joins_for_order_statement_with_jobs(order_options)
      joins = joins_for_order_statement_without_jobs(order_options) || ""

      if order_options
        if order_options.include?('jobs')
          joins += " LEFT OUTER JOIN #{Job.table_name} ON #{Job.table_name}.id = #{TimeEntry.table_name}.job_id"
        end
      end
      joins
    end
  end
end
