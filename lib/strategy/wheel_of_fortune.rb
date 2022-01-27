module Strategy
  class WheelOfFortune
    WORD_SIZE = 5

    attr :dictionary

    def initialize(dictionary:)
      @dictionary = dictionary
    end

    def guess(**args)
      dictionary.words
        .select { |word| word.length == WORD_SIZE }
        .select { |word| (start_letters - word.chars).length == 1 }
        .sample
    end

    private

    def start_letters
      %w(r s t l n e)
    end
  end
end
