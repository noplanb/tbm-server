require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before { authenticate_with_http_basic }

  xdescribe 'GET #receive_test_video' do
    let(:video_id) { '1429630398758' }
    let(:connection) { create(:established_connection) }
    let(:user) { connection.creator }
    let(:sender) { connection.target }
    let!(:s3_credential) do
      cred = S3Credential.instance
      cred.update_credentials(region: 'us-west-1',
                              bucket: 'bucket',
                              access_key: 'access_key',
                              secret_key: 'secret_key')
      cred
    end
    let(:params) { { sender_id: sender.id, id: user.id } }
    let(:attributes) do
      { type: :alert,
        badge: 1,
        payload: { type: 'video_received',
                   from_mkey: sender.mkey,
                   video_id: video_id,
                   host: 'test.host' },
        alert: "New message from #{sender.first_name}" }
    end

    before { allow(controller).to receive(:test_video_id).and_return(video_id) }

    around do |example|
      Connection.find_or_create(user.id, sender.id)
      VCR.use_cassette('s3_put_video', erb: {
                         region: s3_credential.region,
                         bucket: s3_credential.bucket,
                         access_key: s3_credential.access_key,
                         secret_key: s3_credential.secret_key,
                         key: Kvstore.video_filename(sender, user, video_id)
                       }) do
          example.run
      end
    end

    context 'when push user exists' do
      let!(:push_user) do
        PushUser.create_or_update(mkey: user.mkey,
                                  device_platform: user.device_platform,
                                  push_token: 'push_token')
      end

      before { allow_any_instance_of(GenericPushNotification).to receive(:send_notification).and_return(true) }

      it 'expects any instance of PushUser to receive :send_notification with attributes' do
        expect_any_instance_of(PushUser).to receive(:send_notification).with(attributes)
        get :receive_test_video, params
      end

      specify do
        get :receive_test_video, params
        expect(response).to redirect_to(user)
      end

      describe 'event notification' do
        let(:video_filename) { Kvstore.video_filename(sender, user, video_id) }
        let(:event_params1) do
          { initiator: 'user',
            initiator_id: sender.mkey,
            target: 'video',
            target_id: video_filename,
            data: {
              sender_id: sender.mkey,
              sender_platform: sender.device_platform,
              receiver_id: user.mkey,
              receiver_platform: user.device_platform,
              video_filename: video_filename,
              video_id: video_id
            },
            raw_params: {
              'key1' => Kvstore.generate_id_key(sender, user, connection),
              'key2' => video_id,
              'value' => { 'videoId' => video_id }.to_json
            }
          }
        end
        let(:event_params2) do
          { initiator: 'admin',
            initiator_id: nil,
            target: 'video',
            target_id: video_filename,
            data: {
              sender_id: sender.mkey,
              sender_platform: sender.device_platform,
              receiver_id: user.mkey,
              receiver_platform: user.device_platform,
              video_filename: video_filename,
              video_id: video_id
            },
            raw_params: Hash[params.map { |k, v| [k.to_s, v.to_s] }] }
        end

        subject do
          allow(GenericPushNotification).to receive(:send_notification)
          post :receive_test_video, params
        end

        it "emits ['video', 'kvstore', 'received'] and ['video', 'notification', 'received'] events" do
          expect(Zazo::Tool::EventDispatcher).to receive(:emit).with(['video', 'kvstore', 'received'], event_params1).ordered
          expect(Zazo::Tool::EventDispatcher).to receive(:emit).with(['video', 'notification', 'received'], event_params2).ordered
          subject
        end

        it 'Zazo::Tool::EventDispatcher.sqs_client receives :send_message twice', event_dispatcher: true do
          expect(Zazo::Tool::EventDispatcher.sqs_client).to receive(:send_message).twice
          subject
        end
      end
    end

    context 'when push user not exists' do
      specify  do
        expect { get :receive_test_video, params }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe 'GET #establish_connection' do
    let(:creator) { create(:user) }
    let(:target) { create(:user) }
    let(:params) { { id: creator.to_param, target_id: target.to_param } }

    context 'connection status' do
      specify do
        get :establish_connection, params
        connection = Connection.between(creator.id, target.id).first
        expect(connection.status).to eq('established')
      end
    end
  end

  describe 'GET #index' do
    let(:user) { create(:user) }

    describe 'search' do
      context 'by first_name' do
        let(:params) { { query: user.first_name } }
        specify do
          get :index, params
          expect(assigns(:users)).to eq([user])
        end
      end

      context 'by mobile_number' do
        let(:params) { { query: user.mobile_number.gsub('+', '') } }
        specify do
          get :index, params
          expect(assigns(:users)).to eq([user])
        end
      end
    end

    describe 'go to user' do
      context 'by id' do
        let(:params) { { user_id_or_mkey: user.id } }

        specify do
          get :index, params
          expect(response).to redirect_to(user)
        end
      end

      context 'by mkey' do
        let(:params) { { user_id_or_mkey: user.mkey } }

        specify do
          get :index, params
          expect(response).to redirect_to(user)
        end
      end

      context 'when no user found' do
        let(:params) { { user_id_or_mkey: 'fooo' } }

        describe 'alert' do
          specify do
            get :index, params
            expect(flash[:alert]).to be_present
          end
        end
      end
    end
  end
end
