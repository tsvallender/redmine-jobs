class RemoveUniqueNameConstraintFromJobs < ActiveRecord::Migration[6.1]
  def change
    remove_index :jobs, :name
  end
end
