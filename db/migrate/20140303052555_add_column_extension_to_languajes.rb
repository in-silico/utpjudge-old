class AddColumnExtensionToLanguajes < ActiveRecord::Migration
  def change
    add_column :languages, :extension, :string
  end
end
