class AddIsbn13ToBooks < ActiveRecord::Migration[5.0]
  def change
    add_column :books, :isbn13, :string
  end
end
