class CreateBooks < ActiveRecord::Migration[5.0]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author_name
      t.string :author_bio
      t.text :desc
      t.decimal :price
      t.decimal :rating
      t.string :image_url
      t.string :skill
      t.boolean :is_scraped
      t.string :url

      t.timestamps
    end
  end
end
