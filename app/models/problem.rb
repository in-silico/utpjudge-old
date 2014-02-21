class Problem < ActiveRecord::Base
  attr_accessible :name, :notes
  attr_accessible :checker, :pdescription

  validates_presence_of :name


  has_attached_file :pdescription, :path => ":rails_root/protected/problems/:basename:id.:extension", :url => ":basename:id.:extension"
  has_attached_file :checker, :path => ':rails_root/protected/checkers/:basename:id.:extension' , :default_url => 'checker.cpp'
  validates_attachment_size :pdescription, :less_than => 2.megabytes
  validates_attachment_size :checker, :less_than => 2.megabytes

  has_many :exercise_problems ,  :dependent => :destroy
  has_many :exercises, :through=>:exercise_problems
  has_many :testcases,  :dependent => :destroy
end
