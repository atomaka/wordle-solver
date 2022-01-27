module Dictionary
  class Dictionary
    attr_accessor :file

    def initialize(file: "dictionary.txt")
      @file = file
    end

    def words
      @words ||= File.readlines(file).map(&:strip)
    end
  end
end
