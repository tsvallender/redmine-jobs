class RemoveExternalProjectIdFromJobs < ActiveRecord::Migration[6.1]
  def change
    remove_column :jobs, :external_project_id, :integer
  end
end
