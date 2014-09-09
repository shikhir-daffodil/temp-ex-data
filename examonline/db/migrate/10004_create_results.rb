class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.integer :test_id
      t.integer :user_id
      t.integer :correct
      t.integer :incorrect
      t.string :test_time

      t.timestamps
    end
  end
end
