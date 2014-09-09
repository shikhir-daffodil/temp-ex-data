class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :ques
      t.string :quetype
      t.string :multichoice
      t.string :isactive
      t.string :answers
      
      t.timestamps
    end
  end
end
