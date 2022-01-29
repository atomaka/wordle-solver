require "capybara"
require "selenium-webdriver"
require "webdrivers"

require_relative "../nonexistant_guess_error"
require_relative "../played_board"
require_relative "../played_letter"

module Board
  class WordleUnlimited
    attr :session

    def initialize
      @session = Capybara::Session.new(:selenium_chrome)
    end

    def start
      session.visit("https://www.wordleunlimited.com/")
    end

    def answer(guess)
      guess.chars.map(&:upcase).each { |letter| click(letter) }
      click("Enter")

      if answer_invalid?
        clear_answer!
        raise NonexistantGuessError
      end
    end

    def reset!
      click("Enter")
    end

    def winner?
      session.has_text?(:visible, "Winner!", wait: 0)
    end

    def loser?
      session.has_text?(:visible, "You lost!", wait: 0)
    end

    def allowed_letters
      (exact_letters + elsewhere_letters).uniq
    end

    def bad_letters
      session
        .find_all('div.Game-keyboard-button.letter-absent', wait: 0)
        .map(&:text)
        .map(&:downcase)
    end

    def close!
      @session.quit
    end

    def guesses
      locked_in.map { |row| row.text.tr("\n", "").downcase }
    end

    def first_guess?
      guesses.empty?
    end

    def correct_answer
      session.find('div.feedback > div > b').text
    end

    def template
      return Array.new(5, "*") unless locked_in.any?

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
    end

    def state
      PlayedBoard.new(
        locked_in.map do |row|
          letters = row
            .find_all('div.RowL-letter', wait: 0)
            .map do |letter|
              state = if letter.[]("class").split.include?("letter-correct")
                :correct
              elsif letter.[]("class").split.include?("letter-elsewhere")
                :elsewhere
              elsif letter.[]("class").split.include?("letter-absent")
                :absent
              end

              PlayedLetter.new(
                letter: letter.text.downcase,
                state: state
              )
            end
        end
      )
    end

    private

    def exact_letters
      session
        .find_all('div.Game-keyboard-button.letter-correct', wait: 0)
        .map(&:text)
        .map(&:downcase)
    end

    def elsewhere_letters
      session
        .find_all('div.Game-keyboard-button.letter-elsewhere', wait: 0)
        .map(&:text)
        .map(&:downcase)
    end

    def answer_invalid?
      session.has_text?(:visible, "Not a valid word", wait: 2)
    end

    def locked_in
      session.find_all('div.RowL.RowL-locked-in', wait: 0) || []
    end

    def click(key)
      session
        .find('div.Game-keyboard-button', text: /\A#{key}\Z/, wait: 0)
        .click()
    end

    def clear_answer!
      5.times { click("⌫") }
    end
  end
end
