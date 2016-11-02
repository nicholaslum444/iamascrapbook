class AddColumnsToBooks < ActiveRecord::Migration[5.0]
  def change
    add_column :books, :isbn, :string
    add_column :books, :shop, :string
    add_column :books, :description, :text
  end
end
