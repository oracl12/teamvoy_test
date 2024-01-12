# frozen_string_literal: true

require 'rails_helper'
require_relative '../../app/algorithms/jaro'

# rubocop: disable Metrics/BlockLength
RSpec.describe 'SearchEngines', type: :request do
  describe 'GET /index' do
    subject(:get_index) { get '/' }

    context 'file was found' do
      before { get_index }

      it 'renders the index template' do
        expect(response).to render_template(:index)
        expect(response.status).to eq 200
      end

      it 'expect array type data of hashes' do
        expect(assigns(:data)).not_to be_nil
        expect(assigns(:data)).to be_an_instance_of(Array)
        expect(assigns(:data).first).to eq(
                                          {
                                            'Name' => 'A+',
                                            'Type' => 'Array',
                                            'Designed by' => 'Arthur Whitney'
                                          }
                                        )
      end
    end

    context 'file was not found' do
      before do
        allow_any_instance_of(LoadDataService).to receive(:call).and_return(nil)
        get_index
      end

      it 'renders the index template with correct status' do
        expect(response).to render_template(:index)
        expect(response.status).to eq 200
      end

      it 'expects data to be nil' do
        expect(assigns(:data)).to be_nil
      end
    end
  end

  describe 'POST /search' do
    subject(:post_search) { post '/search', params:, as: :json }

    context 'when params are valid' do
      before { post_search }

      context 'with relative search with slightly changed word and high precision' do
        let(:params) do
          { search_input_value: 'miCrososT', search_type_selector_value: '1', precision_selector_value: '0.9' }
        end

        it 'has corresponding http code and message' do
          expect(response).to have_http_status(200)
          json = parse_json(response).reverse
          expect(json.first).to(
            eq(
              {
                'Designed by' => 'Microsoft',
                'Name' => 'X++',
                'Type' => 'Compiled, Object-oriented class-based, Procedural, Reflective'
              }
            )
          )

          expect(json.second).to(
            eq(
              {
                'Designed by' => 'Microsoft',
                'Name' => 'Windows PowerShell',
                'Type' => 'Command line interface, Curly-bracket, Interactive mode, Interpreted, Scripting'
              }
            )
          )
        end
      end

      context 'with relative search with slightly changed word and medium precision' do
        let(:params) do
          { search_input_value: 'MicrosifT', search_type_selector_value: '1', precision_selector_value: '0.8' }
        end

        it 'has corresponding http code and message' do
          expect(response).to have_http_status(200)
          json = parse_json(response).reverse
          expect(json.first).to(
            eq(
              {
                'Designed by' => 'Microsoft',
                'Name' => 'X++',
                'Type' => 'Compiled, Object-oriented class-based, Procedural, Reflective'
              }
            )
          )

          expect(json.second).to(
            eq(
              {
                'Designed by' => 'Microsoft',
                'Name' => 'Windows PowerShell',
                'Type' => 'Command line interface, Curly-bracket, Interactive mode, Interpreted, Scripting'
              }
            )
          )
        end
      end

      context 'with relative search with slightly changed word and low precision' do
        let(:params) do
          { search_input_value: 'MicrosifT', search_type_selector_value: '1', precision_selector_value: '0.7' }
        end

        it 'has corresponding http code and message' do
          expect(response).to have_http_status(200)
          json = parse_json(response).reverse
          expect(json.first).to(
            eq(
              {
                'Designed by' => 'Microsoft',
                'Name' => 'JScript',
                'Type' => 'Curly-bracket, Procedural, Reflective, Scripting'
              }
            )
          )

          expect(json.second).to(
            eq(
              {
                'Designed by' => 'Microsoft',
                'Name' => 'X++',
                'Type' => 'Compiled, Object-oriented class-based, Procedural, Reflective'
              }
            )
          )
        end
      end

      context 'with relative search with changed 2 words' do
        let(:params) do
          { search_input_value: 'mocrosoft compil', search_type_selector_value: '1', precision_selector_value: '0.9' }
        end

        it 'has corresponding http code and message' do
          expect(response).to have_http_status(200)
          json = parse_json(response).reverse
          expect(json.first).to(
            eq(
              {
                'Designed by' => 'Microsoft',
                'Name' => 'X++',
                'Type' => 'Compiled, Object-oriented class-based, Procedural, Reflective'
              }
            )
          )

          expect(json.second).to(
            eq(
              {
                'Designed by' => 'Microsoft',
                'Name' => 'Visual FoxPro',
                'Type' => 'Compiled, Data-oriented, Object-oriented class-based, Procedural'
              }
            )
          )
        end
      end

      context 'with relative search with changed 2 words - second word with decline' do
        let(:params) do
          { search_input_value: 'micrIsoft -compil', search_type_selector_value: '1', precision_selector_value: '0.9' }
        end

        it 'has corresponding http code and message' do
          expect(response).to have_http_status(200)
          json = parse_json(response).reverse
          expect(json.first).to(
            eq(
              {
                'Designed by' => 'Microsoft',
                'Name' => 'Windows PowerShell',
                'Type' => 'Command line interface, Curly-bracket, Interactive mode, Interpreted, Scripting'
              }
            )
          )

          expect(json.second).to(
            eq(
              {
                'Designed by' => 'Microsoft',
                'Name' => 'VBScript',
                'Type' => 'Interpreted, Procedural, Scripting, Object-oriented class-based'
              }
            )
          )
        end
      end

      context 'with exact search and valid word' do
        let(:params) do
          { search_input_value: 'microsoft', search_type_selector_value: '2' }
        end

        it 'has corresponding http code and message' do
          expect(response).to have_http_status(200)
          json = parse_json(response).reverse
          expect(json.first).to(
            eq(
              {
                'Designed by' => 'Microsoft',
                'Name' => 'X++',
                'Type' => 'Compiled, Object-oriented class-based, Procedural, Reflective'
              }
            )
          )
        end
      end

      context 'with exact search and invalid word' do
        let(:params) do
          { search_input_value: 'micrIsoft', search_type_selector_value: '2' }
        end

        it 'has corresponding http code and body' do
          expect(response).to have_http_status(200)
          json = parse_json(response).reverse
          expect(json).to be_empty
        end
      end
    end

    context 'when params are invalid' do
      before { post_search }

      context 'when type is relative but no precision' do
        let(:params) { { search_input_value: 'microsoft', search_type_selector_value: '1' } }

        it 'has corresponding http code and message' do
          expect(response).to have_http_status(422)
          expect(response.body).to eq({ error: 'We are lacking some fields' }.to_json)
        end
      end

      context 'when input is missing' do
        let(:params) { { search_type_selector_value: '2' } }

        it 'has corresponding http code and message' do
          expect(response).to have_http_status(422)
          expect(response.body).to eq({ error: 'We are lacking some fields' }.to_json)
        end
      end

      context 'when type is missing' do
        let(:params) { { search_input_value: 'microsoft' } }

        it 'has corresponding http code and message' do
          expect(response).to have_http_status(422)
          expect(response.body).to eq({ error: 'We are lacking some fields' }.to_json)
        end
      end
    end

    context 'when params are valid but file is missing' do
      let(:params) do
        { search_input_value: 'm', search_type_selector_value: '1', precision_selector_value: '0.8' }
      end

      before do
        allow(File).to receive(:exist?).and_return(false)
        post_search
      end

      it 'renders the index template with correct status' do
        expect(response).to have_http_status(424)
        expect(response.body).to eq({ error: 'We are lacking a file' }.to_json)
      end

      it 'expects data to be nil' do
        expect(assigns(:data)).to be_nil
      end
    end
  end
end
# rubocop: enable Metrics/BlockLength
