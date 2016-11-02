class RemoveDescFromBooks < ActiveRecord::Migration[5.0]
  def change
    remove_column :books, :desc, :text
  end
end
