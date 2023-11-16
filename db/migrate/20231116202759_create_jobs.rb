class CreateJobs < ActiveRecord::Migration[6.1]
  def change
    create_table :jobs do |t|
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.integer :external_project_id
      t.string :name, null: false
      t.references :project, foreign_key: true
      t.string :description
      t.integer :budget
    end
    add_index :jobs, :name, unique: true
  end
end
