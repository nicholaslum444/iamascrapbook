class RemoveColumnsFromBooks < ActiveRecord::Migration[5.0]
  def change
    remove_column :books, :author_bio, :text
    remove_column :books, :rating, :decimal
  end
end
