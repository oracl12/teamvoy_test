# frozen_string_literal: true

module JsonHelpers
  def parse_json(response)
    JSON.parse(response.body)
  end
end
