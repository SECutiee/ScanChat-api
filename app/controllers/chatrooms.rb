# frozen_string_literal: true

require_relative 'app'

# rubocop:disable Metrics/BlockLength
module ScanChat
  # Web controller for ScanChat API
  class Api < Roda
    route('chatrooms') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @chatroom_route = "#{@api_root}/chatrooms"
      routing.on String do |chatr_id|
        @req_chatroom = Chatroom.first(thread_id: chatr_id)

        # GET api/v1/chatrooms/[chatr_id]
        routing.get do
          chatroom = GetChatroomQuery.call(auth: @auth, chatroom: @req_chatroom)

          { data: chatroom }.to_json
        rescue GetChatroomQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetChatroomQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.error "FIND CHATROOM ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        routing.on('messages') do
          # POST api/v1/chatrooms/[thread_id]/messages
          routing.post do
            new_message = AddMessageToChatroom.call(
              auth: @auth,
              chatroom: @req_chatroom,
              message_data: JSON.parse(routing.body.read)
            )

            response.status = 201
            response['Location'] = "#{@msg_route}/#{new_message.id}"
            { message: 'Message saved', data: new_message }.to_json
          rescue AddMessageToChatroom::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue AddMessageToChatroom::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            Api.logger.warn "Could not add message to chatroom: #{e.message}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('members') do
          # PUT api/v1/chatroom/[chatr_id]/members
          routing.put do
            req_data = JSON.parse(routing.body.read)

            member = AddMemberToChatroom.call(
              auth: @auth,
              chatroom: @req_chatroom,
              memb_username: req_data['username']
            )

            { data: member }.to_json
          rescue AddMemberToChatroom::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/chatroom/[chatr_id]/members
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            member = RemoveMemberFromChatroom.call(
              auth: @auth,
              member_username: req_data['username'],
              chatroom_id: chatr_id
            )

            { message: "#{member.username} removed from chatroom",
              data: member }.to_json
          rescue RemoveMemberFromChatroom::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError => e
            Api.logger.error "UNKNOWN ERROR: #{e.message}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        # DELETE api/v1/chatrooms/[thread_id]
        routing.delete String do |thread_id|
          thread = Thread.first(id: thread_id)
          raise 'Chatroom not found' unless thread

          DeleteChatroomByThreadId(thread_id:)
          { message: 'Chatroom deleted' }.to_json
        rescue StandardError => e
          Api.logger.error "UNKNOWN ERROR: #{e.message}"
          routing.halt 404, { message: e.message }.to_json
        end

        routing.on('edit') do
          # PUT api/v1/chatrooms/[thread_id]/edit
          routing.put do
            Api.logger.info('edit_chatroom')
            req_data = JSON.parse(routing.body.read)
            edited_chatroom = EditChatroom.call(
              auth: @auth,
              chatroom: @req_chatroom,
              chatroom_data: req_data
            )

            { data: edited_chatroom }.to_json
          rescue EditChatroom::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end

      routing.is do
        # GET api/v1/chatrooms
        routing.get do
          Api.logger.info('chatrooms')
          chatrooms = ChatroomPolicy::AccountScope.new(@auth_account).viewable
          puts "chatrooms: #{chatrooms}"
          puts JSON.pretty_generate(data: chatrooms)
          JSON.pretty_generate(data: chatrooms)
        rescue StandardError => e
          puts "UNKNOWN ERROR: #{e.message}"
          routing.halt 403, { message: 'Could not find any chatrooms' }.to_json
        end

        # POST api/v1/chatrooms
        routing.post do
          # Api.logger.info('new_chatroom')
          new_chatr = CreateChatroomForOwner.call(
            auth: @auth,
            chatroom_data: JSON.parse(routing.body.read)
          )

          response.status = 201
          response['Location'] = "#{@chatr_route}/#{new_chatr.id}"
          { message: 'Chatroom saved', data: new_chatr }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue CreateChatroomForOwner::ForbiddenError => e
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
