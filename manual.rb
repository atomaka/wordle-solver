#!/usr/bin/env ruby

require 'pry'

all_words = File.readlines("dictionary.txt")
lower = ('a'..'z').to_a
upper = ('A'..'Z').to_a

guesses = []
letters = []
bad_letters = []
template = []
while guesses.size < 6
  print "Your guess: "
  guess = gets.strip
  print "New bad letters: "
  new_bad_letters = gets.strip.chars

  if guesses.size == 0
    guesses << guess
    length = guess.length
    template = Array.new(length, "*")
  end

  if guess == "X"
    guesses.pop
  else
    bad_letters += new_bad_letters
    letters += guess.chars
      .reject { |letter| new_bad_letters.include?(letter) }
      .map(&:downcase)

    guess.chars.each_with_index do |letter, index|
      template[index] = letter if upper.include?(letter)
    end
  end

  guesses << all_words
    .map(&:strip)
    .select { |word| word.length == length }
    .reject { |word| bad_letters.any? { |letter| word.chars.include?(letter) } }
    .select { |word| (letters - word.chars).length == 0 }
    .select do |word|
      template.map(&:downcase).each_with_index.all? do |letter, index|
        letter == "*" || letter == word[index]
      end
  end.sample

  puts "You should guess '#{guesses.last}'"
end


puts guesses
