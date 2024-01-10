# frozen_string_literal: true

class CustomSearchEngineService
  def initialize(data, search_params)
    @data = data
    @keys = @data.first.keys

    @unprocessed_search_params = search_params[:search_input_value]
    @search_type = search_params[:search_type_selector_value]
    @precision = search_params[:precision_selector_value].to_f if search_params.key?(:precision_selector_value)

    @jarow = FuzzyStringMatch::JaroWinkler.create(:native)
  end

  def call
    search
  end

  private

  def define_separate_user_search_tags
    @tags = @unprocessed_search_params.downcase.split(' ')
  end

  def define_user_search_tags
    @tag = @unprocessed_search_params.downcase
  end

  def calculate_distance(tag, word)
    @jarow.getDistance(tag, word.downcase.delete(',.'))
  end

  def calculate_equality(tag, line)
    line.downcase.include?(tag)
  end

  def relative_search(rating_container)
    @data.each_with_index do |hash, index|
      @keys.each do |hash_key|
        words = hash[hash_key].split(' ')
        words.each do |word|
          @tags.each do |tag|
            negative_mark = tag[0] == '-'
            distance = calculate_distance(negative_mark ? tag[1..] : tag, word)

            next if distance < @precision

            rating_container[index] ||= 0
            rating_container[index] += (negative_mark ? -100 : distance)
          end
        end
      end
    end
  end

  def exact_search(rating_container)
    @data.each_with_index do |hash, index|
      @keys.each do |hash_key|
        equal = calculate_equality(@tag, hash[hash_key])

        next unless equal

        rating_container[index] ||= 0
        rating_container[index] += (equal ? 1 : 0)
      end
    end
  end

  def search
    rating_container = {}

    if @search_type == '1'
      # NOT EXACT MATCHES
      # Precision we can change by changing min level in site select
      # looping over each key of hash and of each record, creating hash for each record with its index in array +
      # relevance - each matching bigger then max precise is for us. One record has more matches - has more chances
      # to be in top of search. Sign "-" automatically rejects record if there is match, example:
      # -array - even one match will fully restrict it from being shown at site

      define_separate_user_search_tags
      relative_search(rating_container)
    else
      # EXACT MATCHES
      # checks if our line just includes our tags in a way they are written
      # and rest the same as in previous except "-" isn't working here

      define_user_search_tags
      exact_search(rating_container)
    end

    # selecting and sorting to left only necessary
    return_hash = rating_container
                  .reject { |_index, rating| rating.negative? || rating.zero? }
                  .sort_by { |_index, rating| rating }
                  .last(10)

    # building and returning result hash
    return_hash.map { |index, _value| @data[index] }
  end
end
