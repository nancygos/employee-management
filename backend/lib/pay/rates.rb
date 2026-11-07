require 'bigdecimal'

module Pay
  class Rates
    AS_OF_DATE = Date.new(2026, 1, 1)

    EXPONENTS = {
      "USD" => 2,
      "EUR" => 2,
      "GBP" => 2,
      "INR" => 2,
      "SGD" => 2,
      "AED" => 2,
      "JPY" => 0
    }.freeze
    USD_PER_MAJOR_UNIT = {
      "USD" => "1",
      "EUR" => "1.08",
      "GBP" => "1.27",
      "INR" => "0.012",
      "SGD" => "0.74",
      "AED" => "0.2723",
      "JPY" => "0.0067"
    }.freeze

    def self.to_usd(amount, currency)
      code = currency.to_s.upcase
      major_units = BigDecimal(amount) / (10 ** EXPONENTS.fetch(code))
      usd_major_units = major_units * BigDecimal(USD_PER_MAJOR_UNIT.fetch(code))
      (usd_major_units * 100).round(0, BigDecimal::ROUND_HALF_UP).to_i
    end
  end
end