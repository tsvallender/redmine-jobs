class CreateTimeBudgets < ActiveRecord::Migration[6.1]
  def change
    create_table :time_budgets do |t|
      t.integer :hours, null: false, default: 0
      t.references :job, foreign_key: true, null: false
      t.integer :activity_id, null: true

      t.timestamps
    end

    add_index :time_budgets, [:job_id, :activity_id], unique: true
    # TODO: We should use NULLS NOT DISTINCT to only allow one instance of nil activity per-Job also
    # Requires Postgres 15
  end
end
