require 'rails_helper'

RSpec.describe Connection::SetVisibility do
  let(:connection) { create :established_connection }
  let(:instance)   { described_class.new params.stringify_keys }

  describe '#get_from_map' do
    let(:params) do
      {
        user_mkey:   connection.target.mkey,
        friend_mkey: connection.creator.mkey,
        visibility:  'hidden'
      }
    end
    subject { instance.send :get_from_map, attr[:by], attr[:key] }

    [
      { by: 'established',       key: :mask, expect: [:v, :v] },
      { by: 'hidden_by_creator', key: :mask, expect: [:h, :v] },
      { by: 'hidden_by_target',  key: :mask, expect: [:v, :h] },
      { by: 'hidden_by_both',    key: :mask, expect: [:h, :h] },
      { by: [:v, :v], key: :status, expect: 'established'       },
      { by: [:h, :v], key: :status, expect: 'hidden_by_creator' },
      { by: [:v, :h], key: :status, expect: 'hidden_by_target'  },
      { by: [:h, :h], key: :status, expect: 'hidden_by_both'    }
    ].each do |row|
      context "#{row[:by]} -> #{row[:expect]}" do
        let(:attr) { { by: row[:by], key: row[:key] } }
        it { is_expected.to eq row[:expect] }
      end
    end
  end

  describe '#do' do
    [
      {
        established: [
          { as_initiator: [:creator, :target], hidden: 'hidden_by_creator', visible: 'established' },
          { as_initiator: [:target, :creator], hidden: 'hidden_by_target',  visible: 'established' }]
      }, {
        hidden_by_both: [
          { as_initiator: [:creator, :target], hidden: 'hidden_by_both',    visible: 'hidden_by_target' },
          { as_initiator: [:target, :creator], hidden: 'hidden_by_both',    visible: 'hidden_by_creator' }]
      }, {
        hidden_by_creator: [
          { as_initiator: [:creator, :target], hidden: 'hidden_by_creator', visible: 'established' },
          { as_initiator: [:target, :creator], hidden: 'hidden_by_both',    visible: 'hidden_by_creator' }]
      }
    ].each do |ctx|
      from_status = ctx.keys.first
      context "from #{from_status} status" do
        let(:connection) { create :connection, status: from_status }

        ctx[from_status].each do |test|
          context "#{test[:as_initiator].first} as initiator" do
            let(:params) do
              {
                user_mkey:   connection.send(test[:as_initiator].first).mkey,
                friend_mkey: connection.send(test[:as_initiator].last).mkey,
                visibility:  visibility.to_s
              }
            end

            context 'visibility is hidden' do
              let(:visibility) { :hidden }
              it { expect(instance.send :final_status).to eq test[:hidden] }
              it { expect(instance.do).to eq true }
            end

            context 'visibility is visible' do
              let(:visibility) { :visible }
              it { expect(instance.send :final_status).to eq test[:visible] }
              it { expect(instance.do).to eq true }
            end
          end
        end
      end
    end
  end
end
