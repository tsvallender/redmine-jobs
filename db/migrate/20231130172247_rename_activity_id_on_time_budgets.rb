class RenameActivityIdOnTimeBudgets < ActiveRecord::Migration[6.1]
  def change
    rename_column :time_budgets, :activity_id, :category_id
  end
end
