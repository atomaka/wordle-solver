module Strategy
  class MostCommon
    attr :dictionary, :word_size

    def initialize(dictionary:, word_size: 5)
      @dictionary = dictionary
      @word_size = word_size
    end

    def guess(**args)
      dictionary.words
        .select { |word| word.length == word_size }
        .select { |word| (most_common_letters - word.chars).length == 0 }
        .sample
    end

    private

    def most_common_letters
      @most_common_letters ||= dictionary.words
        .select { |word| word.length == word_size }
        .map(&:chars)
        .flatten
        .tally
        .sort_by { |letter, count| count }
        .reverse
        .map(&:first)
        .first(5)
    end
  end
end
