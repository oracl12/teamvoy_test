# frozen_string_literal: true

class LoadDataService
  def initialize
    @file_path = 'db/db.json'
  end

  def call
    file_contents = File.read(@file_path)
    JSON.parse(file_contents)
  end
end
