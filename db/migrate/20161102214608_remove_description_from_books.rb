class RemoveDescriptionFromBooks < ActiveRecord::Migration[5.0]
  def change
    remove_column :books, :description, :text
  end
end
