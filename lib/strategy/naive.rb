module Strategy
  class Naive
    WORD_SIZE = 5

    attr :dictionary

    def initialize(dictionary:)
      @dictionary = dictionary
    end

    def guess(good_letters:, bad_letters:, **args)
      dictionary.words
        .select { |word| word.length == WORD_SIZE }
        .reject { |word| bad_letters.any? { |letter| word.chars.include?(letter) } }
        .select { |word| (good_letters - word.chars).length == 0 }
        .sample
    end
  end
end
