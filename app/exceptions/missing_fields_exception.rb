# frozen_string_literal: true

class MissingFieldsException < StandardError
  def initialize(message = 'We are lacking some fields')
    super(message)
  end
end
