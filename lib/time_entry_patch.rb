# frozen_string_literal: true

require_dependency 'time_entry'

module TimeEntryPatch
  extend ActiveSupport::Concern

  included do
    belongs_to :job

    before_save :set_job, unless: :job

    def set_job
      return if job.present?

      self.job = Job.default_for(self)
    end
  end
end
