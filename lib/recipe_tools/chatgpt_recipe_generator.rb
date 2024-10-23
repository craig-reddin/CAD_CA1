# lib/recipe_tools/chatgpt_recipe_generator.rb
require "singleton"
require "httparty"

module RecipeTools
  class ChatgptRecipeGenerator
    OPENAI_API_URL = "https://api.openai.com/v1/chat/completions"
    
    def initialize(api_key)
      @api_key = api_key
    end

    def generate_recipe(ingredients, meal_type)
      prompt = build_prompt(ingredients, meal_type)
      response = request_chatgpt(prompt)
      parse_response(response)
    end

    private
    def build_prompt(ingredients, meal_type)
      "Create a recipe for a #{meal_type} using the following ingredients: #{ingredients.join(', ')}. Can you give meal name, ingredients, instructions and prep time and cook time please?"
    end

    def request_chatgpt(prompt)
      response = HTTParty.post(
        OPENAI_API_URL,
        headers: {
          "Authorization" => "Bearer #{@api_key}",
          "Content-Type" => "application/json"
        },
        body: {
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: prompt }],
          max_tokens: 500
        }.to_json
      )

      if response.code != 200
          Rails.logger.error("Error fetching response from OpenAI: #{response.body}")
        return nil
      end

      response.parsed_response
    end

    def parse_response(response)
      puts(response)
      response = JSON.parse(response) if response.is_a?(String)

      if response && response['choices'].is_a?(Array) && response['choices'].any?
        response['choices'][0]['message']['content']
      else
        "Sorry, I couldn't generate a recipe at this time."
      end
    end
  end
end