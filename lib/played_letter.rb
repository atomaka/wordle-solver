class PlayedLetter
  attr :letter, :state

  def initialize(letter:, state:)
    @letter = letter
    @state = state
  end

  def correct?
    state == :correct
  end

  def elsewhere?
    state == :elsewhere
  end

  def absent?
    state == :absent
  end
end
