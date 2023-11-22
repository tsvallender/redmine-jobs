# frozen_string_literal: true

require_dependency 'time_entry'

module TimeEntryPatch
  extend ActiveSupport::Concern

  included do
    belongs_to :job
  end
end
