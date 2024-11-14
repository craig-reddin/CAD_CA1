 require "recipe_tools/chatgpt_recipe_generator"

 class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[ show edit update destroy ]

    # GET /recipes or /recipes.json
    def index
      @recipes = Recipe.all
      render json: @recipes, status: :created, location: @recipe
    end

    # GET /recipes/1 or /recipes/1.json
    def show
      if @recipe
        render json: @recipe, status: :ok
      else
        render json: { error: "Recipe not found" }, status: :not_found
      end
    end

    # GET /recipes/new
    def new
      @recipe = Recipe.new
    end

    # GET /recipes/1/edit
    def edit
    end

    # POST /recipes or /recipes.json
    def create
      snake_case_params = recipe_params.deep_transform_keys { |key| key.to_s.underscore }
      puts(snake_case_params)
      @recipe = Recipe.new(snake_case_params)

      if @recipe.save

        render json: @recipe, status: :created, location: @recipe
      else
        render json: @recipe.errors, status: :unprocessable_entity
      end
    end


    # PATCH/PUT /recipes/1 or /recipes/1.json
    def update
    snake_case_params = recipe_params.deep_transform_keys { |key| key.to_s.underscore }

    if @recipe.update(snake_case_params)
      render json: @recipe, status: :ok
    else
      render json: @recipe.errors, status: :unprocessable_entity
    end
  end


  # DELETE /recipes/1 or /recipes/1.json
  def destroy
    if @recipe.destroy
      render json: { message: "Recipe was successfully destroyed." }, status: :ok
    else
      render json: { errors: @recipe.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def generate_recipe
    ingredients = params[:recipeName].split(",")
    meal_type = params[:mealType]
    api_keyer = ENV["OPENAI_API_KEY"]
    recipe_generator = RecipeTools::ChatgptRecipeGenerator.new(api_keyer)

    @generated_recipe = recipe_generator.generate_recipe(ingredients, meal_type)
    Rails.logger.debug "Generated recipe: #{@generated_recipe}"

    if @generated_recipe.present?
      render json: { success: true, recipe: @generated_recipe }, status: :ok
    else
      render json: { success: false, message: "Error generating recipe. Please try again." }, status: :unprocessable_entity
    end
  end

  private
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(:recipeName, :mealType, :source, :ingredients, :instructions, :preperationTime, :cookingTime)
  end
 end
