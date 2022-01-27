require "capybara"
require "selenium-webdriver"
require "webdrivers"

module Board
  class WordleUnlimited
    attr :guesses, :session

    def initialize
      @guesses = []
      @session = Capybara::Session.new(:selenium_chrome)
    end

    def start
      session.visit("https://www.wordleunlimited.com/")
    end

    def answer(guess)
      guess.chars.map(&:upcase).each { |letter| click(letter) }
      click("Enter")

      answer_invalid? ? clear_answer! : @guesses << guess
    end

    def reset!
      @guesses = []
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

    def first_guess?
      guesses.empty?
    end

    def correct_answer
      session.find('div.feedback > div > b').text
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
