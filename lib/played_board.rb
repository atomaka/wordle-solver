class PlayedBoard < Array
  def good_letters
    (correct_letters + elsewhere_letters).uniq
  end

  def bad_letters
    absent_letters - good_letters
  end

  def correct_letters
    flatten.select(&:correct?).uniq.map(&:letter)
  end

  def elsewhere_letters
    flatten.select(&:elsewhere?).uniq.map(&:letter)
  end

  def absent_letters
    flatten.select(&:absent?).uniq.map(&:letter)
  end
end
