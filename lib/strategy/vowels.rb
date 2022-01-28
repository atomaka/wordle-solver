module Strategy
  class Vowels
    attr :dictionary, :word_size

    def initialize(dictionary:, word_size: 5)
      @dictionary = dictionary
      @word_size = word_size
    end

    def guess(**args)
      dictionary.words
        .select { |word| word.length == word_size }
        .select { |word| (vowels - word.chars).length <= 2 }
        .sample
    end

    private

    def vowels
      %w(a e i o u y)
    end
  end
end
