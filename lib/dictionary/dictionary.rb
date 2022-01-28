module Dictionary
  class Dictionary
    attr_accessor :file

    def initialize(file: "dictionary.txt", **args)
      @file = file
    end

    def words
      @words ||= File.readlines(file).map(&:strip)
    end

    def exclude(word)
    end

    def close!
    end
  end
end
