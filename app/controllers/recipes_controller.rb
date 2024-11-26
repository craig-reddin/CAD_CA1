 require "recipe_tools/chatgpt_recipe_generator"

# The controller that manages all recipe-related actions
class RecipesController < ApplicationController
  # Runs the `set_recipe` method before specific actions to set the @recipe instance variable
  before_action :set_recipe, only: %i[ show edit update destroy ]

  # GET /recipes or /recipes.json
  # Fetches all recipes and renders them as JSON
  def index
    @recipes = Recipe.all
    render json: @recipes, status: :created, location: @recipe
  end

  # GET /recipes/1 or /recipes/1.json
  # Fetches a single recipe by ID and renders it as JSON
  def show
    if @recipe
      render json: @recipe, status: :ok
    else
      # Returns an error if the recipe is not found
      render json: { error: "Recipe not found" }, status: :not_found
    end
  end

  # GET /recipes/new
  # Initializes a new recipe instance
  def new
    @recipe = Recipe.new
  end

  # GET /recipes/1/edit
  # Used to edit an existing recipe 
  def edit
  end

  # POST /recipes or /recipes.json
  # Creates a new recipe using the passed parameters
  def create
    # Converts incoming parameters to snake_case to match Ruby convention
    snake_case_params = recipe_params.deep_transform_keys { |key| key.to_s.underscore }
    puts(snake_case_params) # Logs the parameters to the console for debugging
    @recipe = Recipe.new(snake_case_params)

    if @recipe.save
      # If the recipe is saved successfully, return it as JSON
      render json: @recipe, status: :created, location: @recipe
    else
      # If the recipe cannot be saved, return validation errors
      render json: @recipe.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /recipes/1 or /recipes/1.json
  # Updates an existing recipe
  def update
    # Converts incoming parameters to snake_case to ensure compatibility
    snake_case_params = recipe_params.deep_transform_keys { |key| key.to_s.underscore }

    if @recipe.update(snake_case_params)
      # If update succeeds, return the updated recipe
      render json: @recipe, status: :ok
    else
      # If update fails, return validation errors
      render json: @recipe.errors, status: :unprocessable_entity
    end
  end

  # DELETE /recipes/1 or /recipes/1.json
  # Deletes a recipe by ID
  def destroy
    if @recipe.destroy
      # If delete succeeds, return a success message
      render json: { message: "Recipe was successfully destroyed." }, status: :ok
    else
      # If delete fails, return the associated errors
      render json: { errors: @recipe.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /generate_recipe
  # Generates a recipe using the OpenAI API based on provided ingredients and meal type
  def generate_recipe
    # Extracts ingredients and meal type from parameters
    ingredients = params[:recipeName]
    meal_type = params[:mealType]

    # Retrieves the API key for OpenAI from environment variables
    api_keyer = ENV["OPENAI_API_KEY"]

    # Creates an instance of the recipe generator library
    recipe_generator = RecipeTools::ChatgptRecipeGenerator.new(api_keyer)

    # Calls the generator to generate a recipe based on ingredients and meal type
    @generated_recipe = recipe_generator.generate_recipe(ingredients, meal_type)

    # Logs the generated recipe to help with debugging
    Rails.logger.debug "Generated recipe: #{@generated_recipe}"

    if @generated_recipe.present?
      # If a recipe is successfully generated, return it in JSON format
      render json: { success: true, recipe: @generated_recipe }, status: :ok
    else
      # If generation fails, return an error message
      render json: { success: false, message: "Error generating recipe. Please try again." }, status: :unprocessable_entity
    end
  end

  private

  # Finds a recipe by ID and sets it to the @recipe instance variable
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  # Defines which parameters are allowed for recipes
  # This ensures only the specified fields can be passed into the controller
  def recipe_params
    params.require(:recipe).permit(:recipeName, :mealType, :source, :ingredients, :instructions, :preperationTime, :cookingTime)
  end
end

