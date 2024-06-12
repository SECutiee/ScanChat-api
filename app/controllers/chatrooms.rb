# frozen_string_literal: true

require_relative 'app'

# rubocop:disable Metrics/BlockLength
module ScanChat
  # Web controller for ScanChat API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('chatrooms') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @chatroom_route = "#{@api_root}/chatrooms"
      routing.on String do |chatr_id|
        @req_chatroom = Chatroom.first(thread_id: chatr_id)

        # GET api/v1/chatrooms/[ID]
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
          puts "FIND CHATROOM ERROR: #{e.inspect}"
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

      routing.on('members') do
        # PUT api/v1/chatroom/[chatr_id]/members
        routing.put do
          req_data = JSON.parse(routing.body.read)

          member = AddMember.call(
            account: @auth_account,
            chatroom: @req_chatroom,
            memb_email: req_data['email']
          )

          { data: member }.to_json
        rescue AddMember::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # DELETE api/v1/chatroom/[chatr_id]/members
        routing.delete do
          req_data = JSON.parse(routing.body.read)
          member = RemoveMember.call(
            req_username: @auth_account.username,
            memb_email: req_data['email'],
            chatrroom_id: chatr_id
          )

          { message: "#{member.username} removed from projet",
            data: member }.to_json
        rescue RemoveMember::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
      
      routing.on('members') do
        # PUT api/v1/chatroom/[chatr_id]/members
        routing.put do
          req_data = JSON.parse(routing.body.read)

          member = AddMember.call(
            account: @auth_account,
            chatroom: @req_chatroom,
            memb_email: req_data['email']
          )

          { data: member }.to_json
        rescue AddMember::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # DELETE api/v1/chatroom/[chatr_id]/members
        routing.delete do
          req_data = JSON.parse(routing.body.read)
          member = RemoveMember.call(
            req_username: @auth_account.username,
            memb_email: req_data['email'],
            chatrroom_id: chatr_id
          )

          { message: "#{member.username} removed from chatroom",
            data: member }.to_json
        rescue RemoveMember::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end

      # TODO: problem is that we only get msgb and not the attributes in threads
      # GET api/v1/chatrooms
      routing.is do
        routing.get do
          chatrooms = ChatroomPolicy::AccountScope.new(@auth_account).viewable
          JSON.pretty_generate(data: chatrooms)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any chatrooms' }.to_json
        end

        # POST api/v1/chatrooms
        routing.post do
          new_data = JSON.parse(routing.body.read)
          new_chatr = @auth_account.add_owned_chatroom(new_data)

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
