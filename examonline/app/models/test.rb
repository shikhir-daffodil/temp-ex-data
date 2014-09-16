class Test < ActiveRecord::Base
  validates :duration, :presence => { :message => "of Test is required" }, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 200 }
  validates :quescount, :presence => { :message => "is required" }
  validates :testname, :presence => { :message => "is required" }
  validates :testlogin, :presence => { :message => "is required" }, :uniqueness => true
  validates :testpass, :presence => { :message => "is required" }
end