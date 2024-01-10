# frozen_string_literal: true

class SearchEnginesController < ApplicationController
  before_action :data
  before_action :search_params, only: :search

  def index; end

  def search
    # controller action only to respond json with search results

    respond_to do |format|
      format.json { render json: CustomSearchEngineService.new(@data, search_params).call }
    rescue ArgumentError => e
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  private

  def data
    @data ||= LoadDataService.new.call
  end

  def search_params
    # validation of incoming params

    required_fields = %w[search_input_value search_type_selector_value]
    result = {}

    raise ArgumentError, 'Missing required fields' unless (required_fields - params.keys).empty?

    result[:search_input_value] = params['search_input_value']
    result[:search_type_selector_value] = params['search_type_selector_value']

    if params['search_type_selector_value'] == '1'
      raise ArgumentError, 'Missing required fields' unless params.key?('precision_selector_value')

      result[:precision_selector_value] = params['precision_selector_value']
    end

    result
  end
end
