require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @recipe = recipes(:one)
  end

  test "should get index" do
    get recipes_url, as: :json
    assert_response :success
  end

 test "should create recipe" do
  assert_difference("Recipe.count") do
    post recipes_url, params: { recipe: { recipeName: "Ham and Eggs", mealType: "breakfast",  source: "Chef John", ingredients: "eggs, ham", instructions: "Cook the eggs.", cookingTime: 30, preperationTime: 5 } }, as: :json  
  end

   assert_response :created
 end


  test "should show recipe" do
    get recipe_url(@recipe), as: :json
    assert_response :success
  end

  test "should update recipe" do
    patch recipe_url(@recipe), params: { recipe: { recipeName: "Ham and Eggs", mealType: "breakfast",  source: "Chef John", ingredients: "eggs, ham", instructions: "Cook the eggs.", cookingTime: 45, preperationTime: 5 } }, as: :json
    assert_response :success
    @recipe.reload
    assert_equal @recipe.cooking_time, 45
  end

  test "should not update recipe cooking time 0" do
    patch recipe_url(@recipe), params: { recipe: { recipeName: "Ham and Eggs", mealType: "breakfast",  source: "Chef John", ingredients: "eggs, ham", instructions: "Cook the eggs.", cookingTime: 50, preperationTime: 0 } }, as: :json
    assert_response  :unprocessable_entity
  end

  test "should not update recipe no recipe name" do
    patch recipe_url(@recipe), params: { recipe: { recipeName: "", mealType: "breakfast",  source: "Chef John", ingredients: "eggs, ham", instructions: "Cook the eggs.", cookingTime: 50, preperationTime: 5 } }, as: :json
    assert_response  :unprocessable_entity
  end

  test "should not update recipe no meal type" do
    patch recipe_url(@recipe), params: { recipe: { recipeName: "Breakfast Name", mealType: "",  source: "Chef John", ingredients: "eggs, ham", instructions: "Cook the eggs.", cookingTime: 50, preperationTime: 5 } }, as: :json
    assert_response  :unprocessable_entity
  end
  test "should not update recipe no source" do
    patch recipe_url(@recipe), params: { recipe: { recipeName: "Ham and Eggs", mealType: "breakfast",  source: "", ingredients: "eggs, ham", instructions: "Cook the eggs.", cookingTime: 50, preperationTime: 5 } }, as: :json
    assert_response  :unprocessable_entity
  end
  test "should not update recipe no ingredients" do
    patch recipe_url(@recipe), params: { recipe: { recipeName: "Ham and Eggs", mealType: "breakfast",  source: "Chef John", ingredients: "", instructions: "Cook the eggs.", cookingTime: 50, preperationTime: 5 } }, as: :json
    assert_response  :unprocessable_entity
  end
  test "should not update recipe no instructions" do
    patch recipe_url(@recipe), params: { recipe: { recipeName: "Ham and Eggs", mealType: "breakfast",  source: "Chef John", ingredients: "eggs, ham", instructions: "", cookingTime: 50, preperationTime: 5 } }, as: :json
    assert_response  :unprocessable_entity
  end

  test "should not update recipe 0 preperation time" do
    patch recipe_url(@recipe), params: { recipe: { recipeName: "Ham and Eggs", mealType: "breakfast",  source: "Chef John", ingredients: "eggs, ham", instructions: "", cookingTime: 50, preperationTime: 0 } }, as: :json
    assert_response  :unprocessable_entity
  end

  test "should destroy recipe" do
    assert_difference("Recipe.count", -1) do
      delete recipe_url(@recipe), as: :json
    end

    assert_response :ok
  end
  test "should generate recipe" do
    ingredients = ["ham, cheese eggs"].split(",")  
    meal_type = ["lunch"]
    api_keyer = ENV["OPENAI_API_KEY"]
    recipe_generator = RecipeTools::ChatgptRecipeGenerator.new(api_keyer)

    @generated_recipe = recipe_generator.generate_recipe(ingredients, meal_type)
    Rails.logger.debug "Generated recipe: #{@generated_recipe}"

    assert_not_equal "Error generating recipe. Please try again.",@generated_recipe
  end

  test "should not generate recipe invalid key" do
    ingredients = ["ham, cheese eggs"].split(",") 
    meal_type = ["lunch"]
    api_keyer = "gjgjdjvjofgvjjdfvjdfvodvfodjkfdv"
    recipe_generator = RecipeTools::ChatgptRecipeGenerator.new(api_keyer)

    @generated_recipe = recipe_generator.generate_recipe(ingredients, meal_type)
    Rails.logger.debug "Generated recipe: #{@generated_recipe}"

    assert_equal "Sorry, I couldn't generate a recipe at this time.",@generated_recipe
  end
  
end







 


