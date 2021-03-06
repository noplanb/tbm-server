require 'rails_helper'

RSpec.describe InvitationController, type: :controller do
  let(:user) { create(:user) }

  describe 'GET #invite' do
    let(:params) do
      { first_name: 'John',
        last_name: 'Appleseed',
        mobile_number: '+1 650-111-0000',
        emails: ['test@example.com'] }
    end

    subject do
      authenticate_with_http_digest(user.mkey, user.auth) do
        get :invite, params
      end
    end

    context 'when invitee not exists with given mobile_number' do
      let(:invitee) { User.find_by_raw_mobile_number(params[:mobile_number]) }

      it 'returns http success' do
        subject
        expect(response).to have_http_status(:success)
      end

      context 'invitee status' do
        specify do
          subject
          expect(invitee.status).to eq('invited')
        end
      end

      context 'events notification' do
        it 'emits 3 events' do
          expect(Zazo::Tool::EventDispatcher).to receive(:emit).with(['connection', :established], instance_of(Hash))
          expect(Zazo::Tool::EventDispatcher).to receive(:emit).with(['user', :invited], instance_of(Hash))
          expect(Zazo::Tool::EventDispatcher).to receive(:emit).with(['user', 'invitation_sent'], instance_of(Hash))
          subject
        end

        it 'Zazo::Tool::EventDispatcher.sqs_client receives :send_message 3 times', event_dispatcher: true do
          expect(Zazo::Tool::EventDispatcher.sqs_client).to receive(:send_message).exactly(3).times
          subject
        end
      end

      context 'emails' do
        context 'emails is not array' do
          let(:params) do
            { first_name: 'John',
              last_name: 'Appleseed',
              mobile_number: '+1 650-111-0000',
              emails: 'test@example.com' }
          end

          specify do
            subject
            expect(invitee.emails).to eq(['test@example.com'])
          end
        end

        context 'with invalid' do
          let(:params) do
            { first_name: 'John',
              last_name: 'Appleseed',
              mobile_number: '+1 650-111-0000',
              emails: ['valid@example.com', 'invalid@example'] }
          end

          it 'saves only valid emails' do
            subject
            expect(invitee.emails).to eq(['valid@example.com'])
          end
        end
      end
    end

    context 'when invitee already exists with given mobile_number' do
      let(:invitee_params) do
        { first_name: 'John',
          last_name: 'Appleseed',
          mobile_number: '+1 650-111-0000' }
      end
      let!(:invitee) { create(:user, invitee_params) }

      it 'returns http success' do
        subject
        expect(response).to have_http_status(:success)
      end

      context 'invitee status' do
        specify do
          expect { subject }.to change { invitee.reload.status }.from('initialized').to('invited')
        end
      end

      context 'when registered or verified' do
        let!(:invitee) { create(:user, invitee_params.merge(status: :verified)) }

        context 'invitee status' do
          specify do
            expect { subject }.to_not change { invitee.status }
          end
        end
      end

      context 'emails' do
        specify do
          expect { subject }.to change { invitee.reload.emails }.from([]).to(['test@example.com'])
        end

        context 'preserves existed emails' do
          let!(:invitee) { create(:user, invitee_params.merge(emails: ['test1@example.com'])) }
          specify do
            expect { subject }.to change { invitee.reload.emails }.from(['test1@example.com']).to(['test1@example.com', 'test@example.com'])
          end

          context 'only unique' do
            let!(:invitee) { create(:user, invitee_params.merge(emails: ['test1@example.com', 'test@example.com'])) }
            specify do
              expect { subject }.to_not change { invitee.reload.emails }
            end
          end
        end

        context 'emails is not array' do
          let(:params) do
            { first_name: 'John',
              last_name: 'Appleseed',
              mobile_number: '+1 650-111-0000',
              emails: 'test@example.com' }
          end

          specify do
            subject
            expect(invitee.reload.emails).to eq(['test@example.com'])
          end
        end

        context 'with invalid' do
          let(:params) do
            { first_name: 'John',
              last_name: 'Appleseed',
              mobile_number: '+1 650-111-0000',
              emails: ['valid@example.com', 'invalid@example'] }
          end

          it 'saves only valid emails' do
            subject
            expect(invitee.reload.emails).to eq(['valid@example.com'])
          end
        end
      end

      context 'events notification' do
        let(:event_params1) do
          { initiator: 'user',
            initiator_id: invitee.id_for_events,
            data: {
              event: :invite!,
              from_state: :initialized,
              to_state: :invited
            } }
        end
        let(:event_params2) do
          { initiator: 'user',
            initiator_id: user.id_for_events,
            target: 'user',
            target_id: invitee.id_for_events,
            data: {
              inviter_id: user.id_for_events,
              invitee_id: invitee.id_for_events
            },
            raw_params: params.stringify_keys }
        end

        it 'emits 3 events' do
          expect(Zazo::Tool::EventDispatcher).to receive(:emit).with(['connection', :established], instance_of(Hash))
          expect(Zazo::Tool::EventDispatcher).to receive(:emit).with(['user', :invited], event_params1)
          expect(Zazo::Tool::EventDispatcher).to receive(:emit).with(['user', 'invitation_sent'], event_params2)
          subject
        end

        it 'Zazo::Tool::EventDispatcher.sqs_client receives :send_message 3 times', event_dispatcher: true do
          expect(Zazo::Tool::EventDispatcher.sqs_client).to receive(:send_message).exactly(3).times
          subject
        end
      end
    end
  end

  describe 'POST #direct_invite_message' do
    let(:invitee) { create(:user) }
    let(:params) do
      { mkey: invitee.mkey,
        messaging_platform: 'sms',
        message_status: 'success' }
    end

    context 'when authenticated' do
      subject do
        authenticate_with_http_digest(user.mkey, user.auth) do
          get :direct_invite_message, params
        end
      end

      it 'returns http success' do
        subject
        expect(response).to have_http_status(:success)
      end

      context 'event notification' do
        let(:event_params) do
          { initiator: 'user',
            initiator_id: user.mkey,
            target: 'user',
            target_id: invitee.mkey,
            data: {
              inviter_id: user.mkey,
              invitee_id: invitee.mkey,
              messaging_platform: 'sms',
              message_status: 'success'
            },
            raw_params: params.stringify_keys }
        end
        it_behaves_like 'event dispatchable', %w(user invitation direct_invite_message)
      end
    end

    context 'when not authenticated' do
      subject { get :direct_invite_message, params }

      it 'returns http unauthorized' do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST #update_friend' do
    let(:friend) { create(:user) }
    let!(:connection) { Connection.find_or_create(user.id, friend.id) }
    let(:params) { {} }
    subject do
      authenticate_with_http_digest(user.mkey, user.auth) do
        post :update_friend, params
      end
    end

    context 'when authenticated' do
      context 'when no mkey given' do
        it 'returns http not_found' do
          subject
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'emails' do
        let(:params) do
          { mkey: friend.mkey,
            emails: ['Test@example.com'] }
        end

        specify do
          expect { subject }.to change { friend.reload.emails }.from([]).to(['test@example.com'])
        end

        context 'preserves existed emails' do
          let!(:friend) { create(:user, emails: ['test1@example.com']) }
          specify do
            expect { subject }.to change { friend.reload.emails }.from(['test1@example.com']).to(['test1@example.com', 'test@example.com'])
          end

          context 'only unique' do
            let!(:friend) { create(:user, emails: ['test1@example.com', 'test@example.com']) }
            specify do
              expect { subject }.to_not change { friend.reload.emails }
            end
          end
        end

        context 'emails is not array' do
          let(:params) do
            { mkey: friend.mkey,
              emails: 'test@example.com' }
          end

          specify do
            expect { subject }.to change { friend.reload.emails }.to(['test@example.com'])
          end
        end

        context 'with invalid' do
          let(:params) do
            { mkey: friend.mkey,
              emails: ['valid@example.com', 'invalid@example'] }
          end

          it 'saves only valid emails' do
            expect { subject }.to change { friend.reload.emails }.to(['valid@example.com'])
          end
        end
      end
    end
  end
end
