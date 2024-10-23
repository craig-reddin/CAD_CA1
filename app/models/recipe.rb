class Recipe < ApplicationRecord
  validates :recipe_name, presence: true
  validates :meal_type, presence: true
  validates :source, presence: true
  validates :ingredients, presence: true
  validates :instructions, presence: true
  validates :preperation_time, presence: true, numericality: { greater_than: 0, message: "must be greater than zero" }
  validates :cooking_time, presence: true, numericality: { greater_than: 0, message: "must be greater than zero" }
  validates :meal_type, presence: true
end
