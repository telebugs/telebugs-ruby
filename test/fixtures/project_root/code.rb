# frozen_string_literal: true

class Botley
  RESPONSES = {
    /hello/i => "Oh, hello there! Are you ready to have some fun?",
    /how are you/i => "I'm just a bunch of code, but thanks for asking! How about you?",
    /what is your name/i => "I'm Botley, your friendly (and sometimes cheeky) virtual assistant!",
    /joke/i => "Why don't scientists trust atoms? Because they make up everything!",
    /bye|goodbye|exit/i => "Goodbye! Don't miss me too much!",
    /thank you|thanks/i => "You're welcome! I'm here all week.",
    /default/ => "I'm not sure what you mean, but it sounds intriguing!"
  }

  def initialize
    puts "Botley: Hello! I'm Botley, your virtual assistant. Type 'goodbye' to exit."
  end

  def start
    loop do
      print "You: "
      user_input = gets.chomp
      response = respond_to(user_input)
      puts "Botley: #{response}"
      break if user_input.match?(/bye|goodbye|exit/i)
    end
  end

  private

  def respond_to(input)
    RESPONSES.each do |pattern, response|
      return response if input.match?(pattern)
    end
    RESPONSES[:default]
  end
end

# Start the conversation with Botley
Botley.new.start
