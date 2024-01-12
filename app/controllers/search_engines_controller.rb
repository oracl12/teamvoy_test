# frozen_string_literal: true

class SearchEnginesController < ApplicationController
  def index
    data
  rescue FileNotFoundException => e
    flash[:alert] = e.message
  end

  def search
    # controller action only to respond json with search results

    respond_to { |format| format.json { render json: CustomSearchEngineService.new(data, search_params).call } }
  rescue MissingFieldsException => e
    respond_to { |format| format.json { render json: { error: e.message }, status: :unprocessable_entity } }
  rescue FileNotFoundException => e
    respond_to { |format| format.json { render json: { error: e.message }, status: :failed_dependency } }
  end

  private

  def data
    @data ||= LoadDataService.new.call
  end

  # validation of incoming params
  def search_params
    validate_required_fields
    extract_params
  end

  def validate_required_fields
    raise MissingFieldsException if missing_required_fields?
  end

  def missing_required_fields?
    required_fields = %w[search_input_value search_type_selector_value]
    (required_fields - params.keys).any? ||
      (params['search_type_selector_value'] == '1' && !params.key?('precision_selector_value'))
  end

  def extract_params
    {
      search_input_value: params['search_input_value'],
      search_type_selector_value: params['search_type_selector_value'],
      precision_selector_value: params['precision_selector_value']
    }
  end
end
