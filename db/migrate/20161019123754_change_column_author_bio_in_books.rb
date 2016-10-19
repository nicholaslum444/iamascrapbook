class ChangeColumnAuthorBioInBooks < ActiveRecord::Migration[5.0]
  def change
    change_column 'books', 'author_bio', 'text'
  end
end
