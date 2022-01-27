class Outcome
  attr :correct, :guesses, :state

  def initialize(state:, correct:, guesses:)
    @state = state
    @correct = correct
    @guesses = guesses
  end

  def win?
    state == :win
  end

  def loss?
    state == :loss
  end
end
