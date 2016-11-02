class ChangeColumnForBooks < ActiveRecord::Migration[5.0]
  def change
    change_column :books, :image_url, :text
  end
end
