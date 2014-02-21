class CreateProblems < ActiveRecord::Migration
  def change
    create_table :problems do |t|
      t.string :name
      t.text :description
      t.text :notes
      t.has_attached_file :pdescription
      t.has_attached_file :checker

      t.timestamps
    end
  end
end
