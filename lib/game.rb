require "debug" if RUBY_VERSION.to_i >= 3
require "logger"

require_relative "nonexistant_guess_error"
require_relative "outcome"
require_relative "played_board"
require_relative "played_letter"

require_relative "board/wordle_unlimited"

require_relative "dictionary/dictionary"
require_relative "dictionary/live_dictionary"

require_relative "strategy/basic_board"
require_relative "strategy/most_common"
require_relative "strategy/naive"
require_relative "strategy/template"
require_relative "strategy/vowels"
require_relative "strategy/wheel_of_fortune"

class Game
  attr_reader :board, :dictionary, :start_strategy, :strategy, :outcomes
  attr :logger

  def initialize(
    board: Board::WordleUnlimited,
    dictionary: Dictionary::LiveDictionary,
    start_strategy: Strategy::Vowels,
    strategy: Strategy::BasicBoard
  )
    @board = board.new
    @dictionary = dictionary.new
    @start_strategy = start_strategy.new(dictionary: @dictionary)
    @strategy = strategy.new(dictionary: @dictionary)

    @outcomes = []

    @logger = Logger.new("loss-logger.log")
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
          template: board.template,
          board: board.state,
        )

      begin
        board.answer(guess)
      rescue NonexistantGuessError
        dictionary.exclude(guess)
      end

      if board.winner?
        @outcomes << Outcome.new(
          state: :win,
          correct: board.guesses.last,
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

        logger.info(outcomes.last.to_s)
      end
    end
  end

  def exit!
    dictionary.close!
    board.close!

    puts
    puts "=" * 80
    puts "Won: #{outcomes.select(&:win?).count}"
    puts "Lost: #{outcomes.select(&:loss?).count}"
    puts "=" * 80
  end
end
