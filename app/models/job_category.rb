# frozen_string_literal: true

class JobCategory < Enumeration
  has_many :jobs, foreign_key: :category_id

  OptionName = :enumeration_job_category

  scope :support, -> { where(name: 'Support').first }
  scope :retainer, -> { where(name: 'Retainer').first }
  scope :sprints, -> { where(name: 'Sprints').first }

  def option_name
    OptionName
  end
end
