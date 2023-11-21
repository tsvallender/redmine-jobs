class AddJobToTimelog < ActiveRecord::Migration[6.1]
  def change
    add_reference :time_entries, :job, foreign_key: true
  end
end
