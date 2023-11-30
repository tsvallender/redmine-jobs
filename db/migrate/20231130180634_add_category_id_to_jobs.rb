class AddCategoryIdToJobs < ActiveRecord::Migration[6.1]
  def change
    add_column :jobs, :category_id, :integer
  end
end
