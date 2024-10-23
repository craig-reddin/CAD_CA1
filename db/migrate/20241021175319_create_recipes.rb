class CreateRecipes < ActiveRecord::Migration[7.2]
  def change
    create_table :recipes do |t|
      t.string :recipe_name
      t.string :meal_type
      t.string :source
      t.text :ingredients
      t.string :instructions
      t.integer :preperation_time
      t.integer :cooking_time

      t.timestamps
    end
  end
end
