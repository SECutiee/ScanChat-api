# frozen_string_literal: true

require_relative 'app'

module ScanChat
  # Web controller for ScanChat API
  class Api < Roda
    route('messages') do |routing|
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      @doc_route = "#{@api_root}/messages"

      # GET api/v1/messages/[msg_id]
      routing.on String do |msg_id|
        @req_message = Message.first(id: msg_id)

        routing.get do
          message = GetMessageQuery.call(
            auth: @auth, message: @req_message
          )

          { data: message }.to_json
        rescue GetMessageQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetMessageQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.warn "MESSAGE Error: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
