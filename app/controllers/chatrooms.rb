# frozen_string_literal: true

require_relative 'app'

module ScanChat
  # Web controller for ScanChat API
  class Api < Roda
    route('chatrooms') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @chatroom_route = "#{@api_root}/chatrooms"
      routing.on String do |chatr_id|
        @req_chatroom = Chatroom.first(thread_id: chatr_id)

        # GET api/v1/chatrooms/[chatr_id]
        routing.get do
          chatroom = GetChatroomQuery.call(
            account: @auth_account, chatroom: @req_chatroom
          )
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
              account: @auth_account,
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

        # GET api/v1/chatrooms/[thread_id]
        routing.get do
          # thread = Thread.first(id: thread_id)
          # thread ? thread.to_json : raise('Chatroom not found')
          chatroom = Chatroom.first(thread_id:)
          raise 'Chatroom not found' unless chatroom

          output = chatroom
          JSON.pretty_generate(output)
          chatroom = Chatroom.first(thread_id:)
          raise 'Chatroom not found' unless chatroom

          output = chatroom
          JSON.pretty_generate(output)
        rescue StandardError => e
          Api.logger.error "UNKNOWN ERROR: #{e.message}"
          routing.halt 404, { message: e.message }.to_json
        end

        # DELETE api/v1/chatrooms/[thread_id]
        routing.is do
          routing.delete String do |thread_id|
            thread = Thread.first(id: thread_id)
            raise 'Chatroom not found' unless thread

            DeleteChatroomByThreadId(thread_id:)
            { message: 'Chatroom deleted' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKNOWN ERROR: #{e.message}"
            routing.halt 404, { message: e.message }.to_json
          end
        end

        routing.on('edit') do
          # PUT api/v1/chatrooms/[thread_id]/edit
          routing.put do
            Api.logger.info('edit_chatroom')
            req_data = JSON.parse(routing.body.read)
            edited_chatroom = EditChatroom.call(
              account: @auth_account,
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

        routing.on('members') do
          # PUT api/v1/chatroom/[chatr_id]/members
          routing.put do
            req_data = JSON.parse(routing.body.read)

            member = AddMemberToChatroom.call(
              account: @auth_account,
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
              req_username: @auth_account.username,
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
      end
      # GET api/v1/chatrooms
      routing.is do
        routing.get do
          Api.logger.info('chatrooms')
          chatrooms = ChatroomPolicy::AccountScope.new(@auth_account).viewable
          Api.logger.info("chatrooms: #{chatrooms}")
          JSON.pretty_generate(data: chatrooms)
        rescue StandardError => e
          Api.logger.error "UNKNOWN ERROR: #{e.message}"
          routing.halt 403, { message: 'Could not find any chatrooms' }.to_json
        end

        # POST api/v1/chatrooms
        routing.post do
          # Api.logger.info('new_chatroom')
          new_chatr = CreateChatroomForOwner.call(
            account: @auth_account,
            chatroom_data: JSON.parse(routing.body.read)
          )

          response.status = 201
          response['Location'] = "#{@chatr_route}/#{new_chatr.id}"
          { message: 'Chatroom saved', data: new_chatr }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue StandardError => e
          Api.logger.error "UNKOWN ERROR: #{e.message}"
          routing.halt 500, { message: 'Unknown server error' }.to_json
        end
      end
    end
  end
end
