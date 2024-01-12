# frozen_string_literal: true

class FileNotFoundException < StandardError
  def initialize(message = 'We are lacking a file')
    super(message)
  end
end
