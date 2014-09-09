class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.string :subject
      t.string :createdby
      t.integer :duration
      t.integer :quescount
      t.string :isactive
      t.string :testname
      t.string :testlogin
      t.string :testpass

      t.timestamps
    end
  end
end
