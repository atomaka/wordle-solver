require "debug"

require_relative "outcome"

require_relative "board/wordle_unlimited"
require_relative "dictionary/dictionary"

require_relative "strategy/naive"
require_relative "strategy/wheel_of_fortune"

class Game
  attr_reader :board, :dictionary, :start_strategy, :strategy, :outcomes
  def initialize(
    board: Board::WordleUnlimited,
    dictionary: Dictionary::Dictionary,
    start_strategy: Strategy::WheelOfFortune,
    strategy: Strategy::Naive
  )
    @board = board.new
    @dictionary = dictionary.new
    @start_strategy = start_strategy.new(dictionary: @dictionary)
    @strategy = strategy.new(dictionary: @dictionary)

    @outcomes = []
  end

  def play
    board.start

    loop do
      guess_strategy = board.first_guess? ? start_strategy : strategy

      guess = guess_strategy
        .guess(
          good_letters: board.allowed_letters,
          bad_letters: board.bad_letters,
          guesses: board.guesses,
        )

      board.answer(guess)

      if board.winner?
        @outcomes << Outcome.new(
          state: :win,
          correct: board.correct_answer,
          guesses: board.guesses,
        )
        board.reset!
      elsif board.loser?
        @outcomes << Outcome.new(
          state: :loss,
          correct: board.correct_answer,
          guesses: board.guesses,
        )
        board.reset!
      end
    end
  end

  def exit!
    board.close!

    puts
    puts "=" * 80
    puts "Won: #{outcomes.select(&:win?).count}"
    puts "Lost: #{outcomes.select(&:loss?).count}"
    puts "=" * 80
  end
end
