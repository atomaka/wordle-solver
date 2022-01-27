#!/usr/bin/env ruby

require "pry"
require "logger"

require "capybara"
require "selenium-webdriver"
require "webdrivers"

@logger = Logger.new("run.log")
@logger.info("Beginning new run")

def measure(label, &block)
  start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  result = yield
  finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)

  # @logger.info("#{label.to_s}: #{finish - start} seconds")

  result
end

bad_words = File.readlines("bad-in-dictionary.txt").map(&:strip)
all_words = File.readlines("dictionary.txt").map(&:strip) - bad_words
word_size = 5
ignore = []

session = Capybara::Session.new(:selenium_chrome)
session.visit "https://www.wordleunlimited.com/"

loop do
  bad_letters = measure(:bad) do
    session
      .find_all('div.Game-keyboard-button.letter-absent', wait: 0)
      .map(&:text)
      .map(&:downcase)
  end
  exact_letters = measure(:exact) do
    session
      .find_all('div.Game-keyboard-button.letter-correct', wait: 0)
      .map(&:text)
      .map(&:downcase)
  end
  elsewhere_letters = measure(:elsewhere) do
    session
      .find_all('div.Game-keyboard-button.letter-elsewhere', wait: 0)
      .map(&:text)
      .map(&:downcase)
  end
  letters = exact_letters + elsewhere_letters
  locked_in = measure(:locked) do
    session.find_all('div.RowL.RowL-locked-in', wait: 0)
  end
  guesses = locked_in.map { |row| row.text.tr("\n", "").downcase }
  template = measure(:template) do
    if locked_in.any?
      locked_in
        .last
        .find_all('div.RowL-letter', wait: 0)
        .map do |letter|
          if letter.[]("class").split.include?("letter-correct")
            letter.text.downcase
          else
            "*"
          end
        end
      else
        Array.new(5, "*")
      end
  end
  elsewhere_template = Array.new(5) { [] }
  measure(:block_letters) do
    if locked_in.any?
      locked_in.each do |guess|
        guess
          .find_all('div.RowL-letter', wait: 0).each_with_index do |letter, index|
            if letter.[]("class").split.include?("letter-elsewhere") || letter.[]("class").split.include?("letter-absent")
              elsewhere_template[index] << letter.text.downcase
            end
          end
      end
    end
  end
  if template.none? { |letter| letter == "*" }
    @logger.info("You won with #{guesses.join(', ')}")
    session.find('div.Game-keyboard-button', text: 'Enter', wait: 0).click()
    next
  end

  if letters.none? && locked_in.none?
    letters = "aetsr".chars
  end

  if locked_in.count == 6
    @logger.info("You lost #{guesses.join(', ')}")
    session.find('div.Game-keyboard-button', text: 'Enter', wait: 0).click()
    next
  end

  guess = all_words
    .select { |word| word.length == word_size }
    .reject { |word| bad_letters.any? { |letter| word.chars.include?(letter) } }
    .select { |word| (letters - word.chars).length == 0 }
    .reject { |word| ignore.include?(word) }
    .reject { |word| guesses.include?(word) }
    .select do |word|
      template.each_with_index.all? do |letter, index|
        letter == "*" || letter == word.chars[index]
      end
    end
    .select do |word|
      word.chars.each_with_index.all? do |letter, index|
        (elsewhere_template[index] - [letter]) == elsewhere_template[index]
      end
    end
    .sample

  measure(:guess) do
    guess.chars.map(&:upcase).each do |letter|
      session
        .find('div.Game-keyboard-button', text: /\A#{letter}\Z/, wait: 0)
        .click()
    end
    session
      .find('div.Game-keyboard-button', text: 'Enter', wait: 0)
      .click()
  end

  measure(:not_found) do
    if session.has_text?(:visible, "Not a valid word", wait: 2)
      ignore << guess
      File.open('bad-in-dictionary.txt', 'a') do |file|
        file.write("#{guess}\n")
      end
      5.times do
        session.find('div.Game-keyboard-button', text: '⌫', wait: 0).click()
      end
    end
  end
end
