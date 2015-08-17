require 'rails_helper'

RSpec.describe Connection::SetVisibility do
  let(:connection) { create :established_connection }
  let(:instance)   { described_class.new params }

  describe '#get_from_map' do
    let(:params) {{
      user_mkey:   connection.target.mkey,
      friend_mkey: connection.creator.mkey,
      visibility:  'hidden'
    }}
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
    context 'from established status' do
      context 'creator as initiator' do
        let(:params) {{
          user_mkey:   connection.creator.mkey,
          friend_mkey: connection.target.mkey,
          visibility:  visibility.to_s
        }}

        context 'visibility is hidden' do
          let(:visibility) { :hidden }

          it { expect(instance.send :final_status).to eq 'hidden_by_creator' }
          it { expect(instance.do).to eq true }
        end

        context 'visibility is hidden' do
          let(:visibility) { :visible }

          it { expect(instance.send :final_status).to eq 'established' }
          it { expect(instance.do).to eq true }
        end
      end

      context 'target as initiator' do
        let(:params) {{
          user_mkey:   connection.target.mkey,
          friend_mkey: connection.creator.mkey,
          visibility:  visibility.to_s
        }}

        context 'visibility is hidden' do
          let(:visibility) { :hidden }

          it { expect(instance.send :final_status).to eq 'hidden_by_target' }
          it { expect(instance.do).to eq true }
        end

        context 'visibility is hidden' do
          let(:visibility) { :visible }

          it { expect(instance.send :final_status).to eq 'established' }
          it { expect(instance.do).to eq true }
        end
      end
    end

  end
end
