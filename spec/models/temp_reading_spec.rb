require 'rails_helper'

RSpec.describe TempReading, type: :model do

  let(:now) { Time.now }
  let(:temp_a) { TempReading.create!(created_at: now - 5.minutes, raw_tempf: 200) }
  let(:temp_b) { TempReading.create!(created_at: now - 4.minutes, raw_tempf: 205) }
  let(:temp_c) { TempReading.create!(created_at: now - 3.minutes, raw_tempf: 210) }
  let(:temp_d) { TempReading.create!(created_at: now - 2.minutes, raw_tempf: 215) }
  let(:temp_e) { TempReading.create!(created_at: now - 1.minutes, raw_tempf: 220) }

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
      TempReading.all.each(&:derive_temps!)

      expect(temp_a.reload.tempf).to be_positive
      expect(temp_b.reload.tempf).to be_positive
    end

    context 'when dynamic_temp_factor is zero' do
      before { settings.update!(dynamic_temp_factor: 0 ) } # keep these focused mainly on static_temp_factor and static_temp_offset

      it 'calculates tempf readings which are are higher and further apart when static_temp_factor is higher' do
        temp_a.update!(raw_tempf: 200)
        temp_b.update!(raw_tempf: 205) #

        settings.update!(static_temp_factor: 1.15)
        TempReading.all.each(&:derive_temps!)
        expect(temp_a.reload.tempf).to eq(305.0)
        expect(temp_b.reload.tempf).to eq(310.75)

        settings.update!(static_temp_factor: 1.50)
        TempReading.all.each(&:derive_temps!)
        expect(temp_a.reload.tempf).to eq(375.0)
        expect(temp_b.reload.tempf).to eq(382.5)
        # These readings are higher: 375.0 is higher than 305.0
        # These readings are further apart: they have a difference of 7.5, versus 5.75
      end

      it 'calculates tempf readings that are higher (but not further apart) when static_temp_offset is higher' do
        settings.update!(dynamic_temp_factor: 0) # keep this test focused mainly on static_temp_factor

        temp_a.update!(raw_tempf: 200)
        temp_b.update!(raw_tempf: 205)

        settings.update!(static_temp_offset: 75)
        TempReading.all.each(&:derive_temps!)
        expect(temp_a.reload.tempf).to eq(305.0)
        expect(temp_b.reload.tempf).to eq(310.75)

        settings.update!(static_temp_offset: 100)
        TempReading.all.each(&:derive_temps!)
        expect(temp_a.reload.tempf).to eq(305.0 + 25)
        expect(temp_b.reload.tempf).to eq(310.75 + 25)
      end
    end

    context 'when dynamic_temp_factor is non-zero' do
      before { settings.update!(dynamic_temp_factor: 5 ) }

      context 'when temperatures are going up at various rates' do
        it "doesn't calculate tempf any differently (compared to dynamic_temp_factor being zero)" do
          temp_a.update!(raw_tempf: 200)
          temp_b.update!(raw_tempf: 210)
          temp_c.update!(raw_tempf: 250)
          temp_d.update!(raw_tempf: 290)
          settings.update!(static_temp_factor: 1.15)

          settings.update!(dynamic_temp_factor: 5)
          TempReading.all.each(&:derive_temps!)
          expect(temp_a.reload.tempf).to eq(305.0)
          expect(temp_b.reload.tempf).to eq(316.5)
          expect(temp_c.reload.tempf).to eq(362.5)
          expect(temp_d.reload.tempf).to eq(408.5)

          settings.update!(dynamic_temp_factor: 0)
          TempReading.all.each(&:derive_temps!)
          expect(temp_a.reload.tempf).to eq(305.0) # note, same as above. dynamic_temp_factor being zero didn't make a difference
          expect(temp_b.reload.tempf).to eq(316.5)
          expect(temp_c.reload.tempf).to eq(362.5)
          expect(temp_d.reload.tempf).to eq(408.5)
        end
      end

      context 'when temperatures are going down at a small, steady rate' do
        before do
          temp_a.update!(raw_tempf: 250) # small rate - a 2 degree difference
          temp_b.update!(raw_tempf: 248)
          temp_c.update!(raw_tempf: 246)
          temp_d.update!(raw_tempf: 244)
        end

        it 'calculates tempf to be lower than surface_tempf by a steady difference' do
          TempReading.all.each(&:derive_temps!)

          # the first two don't get this setting applied. Logic looks at 3 records.
          expect(temp_a.reload.tempf).to eq(362.5)
          expect(temp_a.reload.surface_tempf).to eq(362.5) # So surface_tempf is the same as (internal) tempf

          expect(temp_b.reload.tempf).to eq(360.2)
          expect(temp_b.reload.surface_tempf).to eq(360.2) # So surface_tempf is the same as (internal) tempf

          expect(temp_c.reload.tempf).to eq(337.9)
          expect(temp_c.reload.surface_tempf).to eq(357.9)

          expect(temp_d.reload.tempf).to be_within(0.00001).of(335.6)
          expect(temp_d.reload.surface_tempf).to be_within(0.00001).of(355.6)


          expect(temp_c.surface_tempf - temp_c.tempf).to eq(20) # a steady difference
          expect(temp_d.surface_tempf - temp_d.tempf).to eq(20)
        end
      end


      context 'when temperatures are going down at a moderate, steady rate' do
        before do
          temp_a.update!(raw_tempf: 250) # moderate rate - a 5 degree difference
          temp_b.update!(raw_tempf: 245)
          temp_c.update!(raw_tempf: 240)
          temp_d.update!(raw_tempf: 235)
        end

        it 'calculates tempf to be lower than surface_tempf by a larger, but steady difference' do
          TempReading.all.each(&:derive_temps!)

          expect(temp_a.reload.tempf).to eq(362.5)
          expect(temp_a.reload.surface_tempf).to eq(362.5)

          expect(temp_b.reload.tempf).to eq(356.75)
          expect(temp_b.reload.surface_tempf).to eq(356.75)

          expect(temp_c.reload.tempf).to eq(301.0)
          expect(temp_c.reload.surface_tempf).to eq(351.0)

          expect(temp_d.reload.tempf).to eq(295.25)
          expect(temp_d.reload.surface_tempf).to eq(345.25)


          expect(temp_c.surface_tempf - temp_c.tempf).to eq(50) # a steady difference
          expect(temp_d.surface_tempf - temp_d.tempf).to eq(50)
        end
      end

      context 'when temperatures are going down at a fast, steady rate' do
        before do
          temp_a.update!(raw_tempf: 250) # fast rate - a 12 degree difference
          temp_b.update!(raw_tempf: 250 - (12 * 1))
          temp_c.update!(raw_tempf: 250 - (12 * 2))
          temp_d.update!(raw_tempf: 250 - (12 * 3))
        end

        it 'calculates tempf but caps the difference (between surface_tempf and tempf) at max_rate_adjustment_delta' do
          settings.update!(max_rate_adjustment_delta: 10000)
          TempReading.all.each(&:derive_temps!)

          expect(temp_c.reload.surface_tempf - temp_c.tempf).to eq(120)
          expect(temp_d.reload.surface_tempf - temp_d.tempf).to eq(120)

          settings.update!(max_rate_adjustment_delta: 99)
          TempReading.all.each(&:derive_temps!)

          expect(temp_c.reload.surface_tempf - temp_c.tempf).to eq(99) # capped at max_rate_adjustment_delta
          expect(temp_d.reload.surface_tempf - temp_d.tempf).to eq(99)
        end
      end

      context 'when the temperatures are dropping, but there is an outlier' do
        before do
          temp_a.update!(raw_tempf: 250)
          temp_b.update!(raw_tempf: 249)
          temp_c.update!(raw_tempf: 248)
          temp_d.update!(raw_tempf: 246) # outlier, too low
          temp_e.update!(raw_tempf: 246)
        end

        it 'smooths over the outlier by computing tempf more conservatively' do
          TempReading.all.each(&:derive_temps!)

          expect(temp_a.reload.tempf).to eq(362.5)
          expect(temp_a.reload.surface_tempf).to eq(362.5)

          expect(temp_b.reload.tempf).to eq(361.34999999999997)
          expect(temp_b.reload.surface_tempf).to eq(361.34999999999997)

          expect(temp_c.reload.tempf).to eq(350.2)
          expect(temp_c.reload.surface_tempf).to eq(360.2)

          expect(temp_d.reload.tempf).to eq(347.9) # If we just looked at the past reading, this would be 337.9, a lot lower!
          expect(temp_d.reload.surface_tempf).to eq(357.9)

          expect(temp_e.reload.tempf).to eq(357.9)
          expect(temp_e.reload.surface_tempf).to eq(357.9)


          expect(temp_c.reload.surface_tempf - temp_c.tempf).to eq(10)
          expect(temp_d.reload.surface_tempf - temp_d.tempf).to eq(10) # If we just looked at the past reading, this would be 20, a lot lower!
          expect(temp_e.reload.surface_tempf - temp_e.tempf).to eq(0)
        end
      end
    end
  end
end
