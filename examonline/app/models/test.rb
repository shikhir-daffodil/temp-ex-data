class Test < ActiveRecord::Base
  validates :duration, :presence => { :message => "of Test is required" }
  validates :quescount, :presence => { :message => "is required" }
  validates :testname, :presence => { :message => "is required" }
  validates :testlogin, :presence => { :message => "is required" }, :uniqueness => true
  validates :testpass, :presence => { :message => "is required" }
end