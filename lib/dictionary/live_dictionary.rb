module Dictionary
  class LiveDictionary
    attr_accessor :bad_file, :bad_file_name, :bad_words, :file, :file_name

    def initialize(file: "dictionary.txt", bad_file: "bad-in-dictionary.txt")
      @bad_file_name = bad_file
      @file_name = file

      @bad_file = File.open(bad_file, "a")
      @bad_words = []
    end

    def words
      @starting_words ||= dictionary_words - starting_bad_words

      @starting_words - bad_words
    end

    def exclude(word)
      @bad_words << word
      bad_file.write("#{word}\n")
      bad_file.flush
    end

    def close!
      bad_file.close
    end

    private

    def dictionary_words
      @dictionary_words ||= File.readlines(file_name).map(&:strip)
    end

    def starting_bad_words
      @starting_bad_words ||= File.readlines(bad_file_name).map(&:strip)
    end
  end
end
