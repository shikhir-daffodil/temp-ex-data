class Subject < ActiveRecord::Base
  validates :subject, :uniqueness => { case_sensitive: false }, :presence => true
end
