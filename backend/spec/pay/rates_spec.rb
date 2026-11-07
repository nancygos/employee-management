require "rails_helper"

RSpec.describe Pay::Rates do
  it "leaves a US salary unchanged" do
    expect(described_class.to_usd(10_000_000, "USD")).to eq(10_000_000)
  end

  it "converts rupees to USD cents" do
    expect(described_class.to_usd(100_000_000, "INR")).to eq(1_200_000)
  end

  it "converts yen, which have no minor units" do
    expect(described_class.to_usd(10_000_000, "JPY")).to eq(6_700_000)
  end
end