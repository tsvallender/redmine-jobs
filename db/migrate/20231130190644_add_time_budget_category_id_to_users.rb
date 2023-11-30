class AddTimeBudgetCategoryIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :time_budget_category_id, :integer
  end
end
