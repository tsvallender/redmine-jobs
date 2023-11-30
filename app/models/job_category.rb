# frozen_string_literal: true

class JobCategory < Enumeration
  has_many :jobs, foreign_key: :category_id

  OptionName = :enumeration_job_category

  def option_name
    OptionName
  end
end
