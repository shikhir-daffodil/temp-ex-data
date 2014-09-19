class Question < ActiveRecord::Base
  has_many :question_options, dependent: :destroy
  validates :ques, :presence => true, :length => { :in => 0..255 }, :uniqueness => { :message => "Question Already Exists" }

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |question|
        csv << question.attributes.values_at(*column_names)
      end
    end
  end
  
end