# frozen_string_literal: true

Rails.application.routes.draw do
  root 'search_engines#index'

  post '/search', to: 'search_engines#search'
end
