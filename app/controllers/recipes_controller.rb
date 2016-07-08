class RecipesController < ApplicationController
	before_action :find_recipe, only: [:show, :edit, :update, :destroy]
	before_action :authenticate_user!, except: [:index, :show, :search]
	before_action :setup_keys

	def search
		if params[:search].present?
			@search_params = params[:search]
			retrieve_foods_from_api

      		@recipes = Recipe.search params[:search], operator: "or"
    	else
      		@recipes = Recipe.all
    	end
	end

	def index
		@recipe = Recipe.all.order("created_at DESC")
	end

	def show
	end

	def new
		@recipe = current_user.recipes.build
	end

	def create
		@recipe = current_user.recipes.build(recipe_params)

		if @recipe.save
			redirect_to @recipe, notice: "Successfully created new recipe"
		else
			render 'new'
		end
	end

	def edit
	end

	def update
		if @recipe.update(recipe_params)
			redirect_to @recipe
		else
			render "edit"
		end
	end

	def destroy
		@recipe.destroy
		redirect_to root_path, notice: "Successfully deleted recipe"
	end

	private 

	def setup_keys
	 	@app_id = "c5975da7"
     	@app_key = "5cc84166d69454f54ed43fb1bcb9b858"
    end

	def retrieve_foods_from_api
		url = "https://api.edamam.com/search?q=#{ @search_params }&app_id=#{ @app_id }&app_key=#{ @app_key }"
		encoded_url = URI.encode(url.strip)
		uri = URI.parse(encoded_url)
		@recipe_data = HTTParty.get uri if uri

		# Organizing the recipe array
		@recipes = []

		@recipe_data["hits"].first(2).each do |recipe|
			@recipes << add_to_database(recipe)
		end
		
		@recipes
	end

	# Adding recipes to database
	def add_to_database(recipe)
		# Parsing the recipe line
		recipe_db = Recipe.new(
			title: recipe["recipe"]["label"].to_s,
			image: recipe["recipe"]["image"].to_s,
			description: recipe["recipe"]["source"].to_s,
			user_id: 1
			)
		recipe_db.save
		puts recipe_db.errors.messages
		puts "ID: #{recipe_db.id}"
		puts "TITLE: #{recipe_db.title}"
		puts "IMAGE: #{recipe_db.image}"
		# Parsing the ingredients line
		recipe["recipe"]["ingredientLines"].each do |ingredient|
			# Retrieving the ingredient
			ingredient_db = Ingredient.create(
				name: ingredient,
				recipe_id: recipe_db.id
				)
			recipe_db.ingredients << ingredient_db
		end

		recipe_db
	end

	def recipe_params
		params.require(:recipe).permit(:title, :description, :image,
			ingredients_attributes: [:id, :name, :_destroy],
			directions_attributes: [:id, :step, :_destroy])
	end

	def find_recipe
		@recipe = Recipe.find(params[:id])
	end

end
