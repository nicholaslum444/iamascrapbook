class RemoveIsbnFromBooks < ActiveRecord::Migration[5.0]
  def change
    remove_column :books, :isbn, :string
  end
end
