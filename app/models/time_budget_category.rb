# frozen_string_literal: true

class TimeBudgetCategory < Enumeration
  has_many :time_budgets, foreign_key: :category_id

  OptionName = :enumeration_time_budget_category

  def option_name
    OptionName
  end
end
