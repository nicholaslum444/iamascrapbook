class CreateSkills < ActiveRecord::Migration[5.0]
  def change
    create_table :skills do |t|
      t.string :area
      t.string :value

      t.timestamps
    end
  end
end
