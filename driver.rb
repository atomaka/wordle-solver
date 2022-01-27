#!/usr/bin/env ruby

require_relative "lib/game"

game = Game.new

trap "SIGINT" do
  game.exit!
  exit 130
end

game.play
