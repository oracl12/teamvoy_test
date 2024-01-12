# frozen_string_literal: true

class JaroAlgorithm
  def initialize(word1, word2)
    @s1 = word1.downcase
    @s2 = word2.downcase
    @match_count = 0
    @transpositions = 0
    @max_distance = [@s1.length, @s2.length].max / 2 - 1
  end

  def distance
    return 1.0 if @s1 == @s2

    @s1.each_char.with_index do |char, index|
      next unless (0..index + @max_distance).cover?(@s2.index(char))

      @match_count += 1
      @transpositions += 0.5 if char != @s2[index]
    end

    return 0.0 if @match_count.zero?

    winkler_addition(jaro)
  end

  private

  def jaro
    (@match_count / @s1.length.to_f + @match_count / @s2.length.to_f +
      (@match_count - @transpositions) / @match_count.to_f) / 3
  end

  def winkler_addition(jaro)
    prefix_length = 0
    @s1.each_char.with_index do |char, index|
      break if char != @s2[index]

      prefix_length += 1
    end

    jaro + (prefix_length * 0.1 * (1 - jaro))
  end
end
