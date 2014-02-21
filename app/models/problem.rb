class Problem < ActiveRecord::Base
  attr_accessible :name, :notes
  attr_accessible :checker, :pdescription,  :chlang

  validates_presence_of :name, :chlang


  has_attached_file :pdescription, :path => ":rails_root/protected/problems/:basename:id.:extension", :url => ":basename:id.:extension"
  has_attached_file :checker, :path => ':rails_root/protected/checkers/:basename:id.:extension', :url => ':basename:id.:extension'
  validates_attachment_presence :checker
  validates_attachment_size :pdescription, :less_than => 2.megabytes
  validates_attachment_size :checker, :less_than => 2.megabytes
  validates_attachment_content_type :checker, :content_type => /\A*/
  validates_attachment_content_type :pdescription, :content_type => /\A*/

  has_many :exercise_problems ,  :dependent => :destroy
  has_many :exercises, :through=>:exercise_problems
  has_many :testcases,  :dependent => :destroy
end
