RSpec.describe Order, type: :model do

  it { is_expected.to have_many(:logs) }
  it { is_expected.to have_many(:fx_signals) }
  it { is_expected.to have_one(:position) }
  it { is_expected.to belong_to(:pair) }
  it { is_expected.to belong_to(:trading_strategy) }

  it { is_expected.to validate_presence_of(:pair_id) }
  it { is_expected.to validate_presence_of(:direction) }
  it { is_expected.to validate_presence_of(:size) }
  it { is_expected.to validate_presence_of(:entry) }

  describe "#expired?" do
    let(:order) { create(:order, expired_at: Time.current - 4.hours) }

    subject { order.expired? }

    it { is_expected.to be_truthy }

    context "when expired is nil" do
      let(:order) { create(:order, expired_at: nil) }

      it { is_expected.to be_falsey }
    end
  end

end
