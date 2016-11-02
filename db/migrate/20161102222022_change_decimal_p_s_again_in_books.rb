class ChangeDecimalPSAgainInBooks < ActiveRecord::Migration[5.0]
  def change
    change_column :books, :price, :decimal, :precision => 10, :scale => 2
  end
end
