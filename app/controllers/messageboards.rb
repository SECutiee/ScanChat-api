# frozen_string_literal: true

require_relative 'app'

module ScanChat
  # Web controller for ScanChat API
  class Api < Roda
    route('messageboards') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @chatroom_route = "#{@api_root}/messageboards"
      routing.on String do |msgb_id|
        @req_messageboard = Messageboard.first(id: msgb_id)

        # GET api/v1/messageboards/[ID]
        routing.get do
          messageboard = GetMessageboardQuery.call(auth: @auth, messageboard: @req_messageboard)

          { data: messageboard }.to_json
        rescue GetMessageboardQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetMessageboardQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.error "FIND MESSAGEBOARD ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        routing.on('messages') do
          # POST api/v1/messageboards/[thread_id]/messages
          routing.post do
            new_message = AddMessageToMessageboard.call(
              auth: @auth,
              messageboard: @req_messageboard,
              message_data: JSON.parse(routing.body.read)
            )

            response.status = 201
            response['Location'] = "#{@msg_route}/#{new_message.id}"
            { message: 'Message saved', data: new_message }.to_json
          rescue AddMessageToMessageboard::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue AddMessageToMessageboard::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            Api.logger.warn "Could not add message to messageboard: #{e.message}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end

      # DELETE api/v1/messageboards/[thread_id]
      routing.delete String do |thread_id|
        thread = Thread.first(id: thread_id)
        raise 'Messageboard not found' unless thread

        DeleteMessageboardByThreadId(thread_id:)
        { message: 'Messageboard deleted' }.to_json
      rescue StandardError => e
        Api.logger.error "UNKNOWN ERROR: #{e.message}"
        routing.halt 404, { message: e.message }.to_json
      end

      # TODO: problem is that we only get msgb and not the attributes in threads
      # GET api/v1/messageboards
      routing.is do
        routing.get do
          messageboards = MessageboardPolicy::AccountScope.new(@auth_account).viewable
          JSON.pretty_generate(data: messageboards)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any messageboards' }.to_json
        end

        # POST api/v1/messageboards
        routing.post do
          new_msgb = CreateMessageboardForOwner.call(
            auth: @auth,
            masseageboard_data: JSON.parse(routing.body.read)
          )

          response.status = 201
          response['Location'] = "#{@msgb_route}/#{new_msgb.id}"
          { message: 'Messageboard saved', data: new_msgb }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue CreateMessageboardForOwner::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.error "UNKOWN ERROR: #{e.message}"
          routing.halt 500, { message: 'Unknown server error' }.to_json
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
