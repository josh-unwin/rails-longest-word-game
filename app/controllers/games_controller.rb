require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def initialize()
    super
  end

  def new
    @letters = []
    @number_of_letters = 10

    @number_of_letters.times do
      @letters << ('a'..'z').to_a[rand(26)]
    end
  end

  def a_word?
    api_return = open("https://wagon-dictionary.herokuapp.com/#{@user_word}").read
    convert_to_json = JSON.parse(api_return)

    (convert_to_json["found"] == true)
  end

  def in_letters?
    # Create array of characters from word
    chars_array = @user_word.chars

    #Iterate through array of characters, delete first instance of the iteration
    # in the grid if exists. If grid is becomes empty, then return false.
    # if letter is missing from grid, return false. Otherwise, true!
    chars_array.each do |char|
      return false if @letters.empty?

      if @letters.include?(char)
        @letters.delete_at(@letters.index(char))
      else
        return false
      end
    end
    true
  end

  def score_calc
    score = 0
    score += (@user_word.length * 2)

    if (0..5).include? @time_taken.round then score += 4
    elsif (5..10).include? @time_taken.round then score += 3
    elsif (11..20).include? @time_taken.round then score += 2
    elsif (21..30).include? @time_taken.round then score += 1
    end
    return score
  end

  def score
    start_time = Time.new(params[:start_time])
    end_time = Time.now
    @time_taken = end_time - start_time
    @user_word = params[:user_word]
    @letters = params[:letters].split
    @score = score_calc
    session[:user_score] = session[:user_score] + @score
    @total_score = session[:user_score];
    if a_word? && in_letters?
      @result = "Well done, you found a word!"
    else
      @feedback = "#{@user_word} is not a valid word." if !a_word?
      @feedback = "#{@feedback} Your word contained letters not in the provided list." if !in_letters?
    end
  end
end
