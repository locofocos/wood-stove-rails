
require 'rails_helper'

RSpec.describe TempReading, type: :model do

  let(:now) { Time.now }
  let(:temp_a) { TempReading.create!(created_at: now - 3.minutes, raw_tempf: 200) }
  let(:temp_b) { TempReading.create!(created_at: now - 2.minutes, raw_tempf: 205) }
  let(:temp_c) { TempReading.create!(created_at: now - 1.minutes, raw_tempf: 210) }

  let!(:settings) do
    Settings.create!(
      static_temp_factor: 1.15,
      static_temp_offset: 75,
      dynamic_temp_factor: 5,
      max_rate_adjustment_delta: 100
    )
  end

  describe '#derive_temps' do
    it 'sets a valid temp_f' do
      temp_a.update!(raw_tempf: 200)
      temp_b.update!(raw_tempf: 205)
      temp_c.update!(raw_tempf: 210)
      TempReading.all.each(&:derive_temps!)

      expect(temp_a.reload.tempf).to be_positive
      expect(temp_b.reload.tempf).to be_positive
      expect(temp_c.reload.tempf).to be_positive
    end
  end
end
