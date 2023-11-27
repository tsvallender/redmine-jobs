# frozen_string_literal: true

require_dependency 'project'

module ProjectPatch
  extend ActiveSupport::Concern

  included do
    has_many :jobs
  end
end
