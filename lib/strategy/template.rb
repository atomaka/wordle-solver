module Strategy
  class Template
    attr :dictionary, :word_size

    def initialize(dictionary:, word_size: 5)
      @dictionary = dictionary
      @word_size = word_size
    end

    def guess(good_letters:, bad_letters:, guesses:, template:, **args)
      dictionary.words
        .select { |word| word.length == word_size }
        .reject { |word| bad_letters.any? { |letter| word.chars.include?(letter) } }
        .select { |word| (good_letters - word.chars).length == 0 }
        .reject { |word| guesses.include?(word) }
        .select do |word|
          template.each_with_index.all? do |letter, index|
            letter == "*" || letter == word.chars[index]
          end
        end
        .sample
    end
  end
end
