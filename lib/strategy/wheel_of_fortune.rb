module Strategy
  class WheelOfFortune
    attr :dictionary, :word_size

    def initialize(dictionary:, word_size: 5)
      @dictionary = dictionary
      @word_size = word_size
    end

    def guess(**args)
      dictionary.words
        .select { |word| word.length == word_size }
        .select { |word| (start_letters - word.chars).length == 1 }
        .sample
    end

    private

    def start_letters
      %w(r s t l n e)
    end
  end
end
