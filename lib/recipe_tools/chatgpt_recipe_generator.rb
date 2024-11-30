# Provides a Singleton design pattern
require "singleton"
# Used for making HTTP requests
require "httparty"


module RecipeTools
  class ChatgptRecipeGenerator
    # Base URL for making requests to the OpenAI ChatGPT API
    API_URL = "https://api.openai.com/v1/chat/completions"

    # Stores the API key when object is initialised
    def initialize(api_key)
      @api_key = api_key
    end

    # Method to generate a recipe
    def generate_recipe(ingredients, meal_type)
       # Build the input prompt for ChatGPT
      prompt = build_prompt(ingredients, meal_type)
      # Send the prompt to OpenAI and fetch the response
      response = request_chatgpt(prompt)           
      # Return the generated recipe from the response
      parse_response(response)                     
    end

    private

    # Builds a prompt for OpenAI API call
    def build_prompt(ingredients, meal_type)
      "Create a recipe for a #{meal_type} using the following ingredients: #{ingredients}. Can you give meal name, ingredients, instructions and prep time and cook time please?"
    end

    # Makes an HTTP POST request with the prompt, API key, and parameters
    def request_chatgpt(prompt)
      response = HTTParty.post(
        API_URL,
        headers: {
           # Stored API key for request
          "Authorization" => "Bearer #{@api_key}",
           # Request body is JSON
          "Content-Type" => "application/json"   
        },
        body: {
          # The ChatGPT model being used
          model: "gpt-3.5-turbo",  
          # Includes the user prompt in the request               
          messages: [ { role: "user", content: prompt } ],
          # Sets the maximum number of tokens in the response - originally 150. 500 chosen for better developed responses.
          max_tokens: 500                         
        }.to_json
      )

      # Log an error message if the API call fails for debugging
      if response.code != 200
        Rails.logger.error("Error fetching response from OpenAI: #{response.body}")
        return ("Error fetching response from OpenAI")
      end
      # Parses the body of the HTTP response if it is in JSON format 
      response.parsed_response
    end

    # Handles both raw and parsed JSON responses
    def parse_response(response)
      puts(response) # prints response for debugging.

      # Ensures the response is parsed JSON
      response = JSON.parse(response) if response.is_a?(String)

      # Checks if the response is not null, "choices" is an array and the choices is not null.
      if response && response["choices"].is_a?(Array) && response["choices"].any?
        # Returns the recipe content from the first choice
        response["choices"][0]["message"]["content"]
      else
        "Sorry, I couldn't generate a recipe at this time." 
      end
    end
  end
end
