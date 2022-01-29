module Strategy
  class BasicBoard
    attr :dictionary, :word_size

    def initialize(dictionary:, word_size: 5)
      @dictionary = dictionary
      @word_size = word_size
    end

    def guess(board:, **args)
      transposed_board = board.transpose
      dictionary.words
        .select { |word| word.length == word_size }
        .reject { |word| (word.chars & board.bad_letters).any? }
        .select { |word| (board.good_letters - word.chars).length == 0 }
        .reject do |word| # any word has character where board has letter absent
          transposed_board.each_with_index.any? do |letters, index|
            letters.reject(&:correct?).map(&:letter).include?(word[index])
          end
        end
        .select do |word| # make sure correct letters used in right spot
          transposed_board.each_with_index.all? do |letters, index|
            correct_letter = letters.select(&:correct?).first

            !correct_letter || word[index] == correct_letter.letter
          end
        end
        .sample
    end
  end
end
