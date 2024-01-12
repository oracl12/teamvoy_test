# frozen_string_literal: true

require_relative '../algorithms/jaro'

class CustomSearchEngineService
  def initialize(data, search_params)
    @data = data
    @keys = @data.first.keys

    @unprocessed_search_params = search_params[:search_input_value]
    @search_type = search_params[:search_type_selector_value]
    @precision = search_params[:precision_selector_value].to_f if search_params.key?(:precision_selector_value)

    @rating_container = {}
  end

  # Search_Type = 1 -> NOT EXACT MATCHES
  # Precision we can change by changing min level in site select
  # looping over each key of hash and of each record, creating hash for each record with its index in array +
  # relevance - each matching bigger then max precise is for us. One record has more matches - has more chances
  # to be in top of search. Sign "-" automatically rejects record if there is match, example:
  # -array - even one match will fully restrict it from being shown at site
  # Search_Type = 0 EXACT MATCHES
  # checks if our line just includes our tags in a way they are written
  # and rest the same as in previous except "-" isn't working here
  def call
    if @search_type == '1'
      define_separate_user_search_tags
      relative_search
    else
      define_user_search_tags
      exact_search
    end

    # selecting and sorting to left only necessary
    return_hash = @rating_container.reject { |_index, rating| rating.negative? || rating.zero? }
                                   .sort_by { |_index, rating| rating }.last(10)

    # building and returning result hash
    return_hash.map { |index, _value| @data[index] }
  end

  private

  def define_separate_user_search_tags
    @tags = @unprocessed_search_params.downcase.split(' ')
  end

  def define_user_search_tags
    @tag = @unprocessed_search_params.downcase
  end

  def calculate_distance(tag, word)
    JaroAlgorithm.new(tag, word.delete(',.')).distance
  end

  def calculate_equality(tag, line)
    line.downcase.include?(tag)
  end

  def rating_update(index, conditional_var, param_true, param_false)
    @rating_container[index] ||= 0
    @rating_container[index] += (conditional_var ? param_true : param_false)
  end

  def search_hash(hash, index)
    @keys.each do |hash_key|
      hash[hash_key].split(' ').each do |word|
        search_tags(word, index)
      end
    end
  end

  def search_tags(word, index)
    @tags.each do |tag|
      negative_mark = tag[0] == '-'
      distance = calculate_distance(negative_mark ? tag[1..] : tag, word)

      next if distance < @precision

      rating_update(index, negative_mark, -100, distance)
    end
  end

  def relative_search
    @data.each_with_index do |hash, index|
      search_hash(hash, index)
    end
  end

  def exact_search
    @data.each_with_index do |hash, index|
      @keys.each do |hash_key|
        equal = calculate_equality(@tag, hash[hash_key])

        next unless equal

        rating_update(index, equal, 1, 0)
      end
    end
  end
end
