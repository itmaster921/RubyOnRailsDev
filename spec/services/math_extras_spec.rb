require 'rails_helper'

describe MathExtras do
  describe '#substract_ranges' do
    it 'should return empty array if substracted range covers given' do
      expect(MathExtras.substract_ranges([(1..10)], [(1..10)])).to eq []
    end

    it 'should return given array if substracted range not covers given' do
      expect(MathExtras.substract_ranges([(1..10)], [(11..20)])).to eq [(1..10)]
    end

    it 'should return array with lesser range if substracted range overlaps start of given' do
      expect(MathExtras.substract_ranges([(1..10)], [(0..3)])).to eq [(4..10)]
    end

    it 'should return array with lesser range if substracted range overlaps end of given' do
      expect(MathExtras.substract_ranges([(1..10)], [(7..12)])).to eq [(1..6)]
    end

    it 'should return array of lesser ranges if substracted range overlaps middle of given' do
      expect(MathExtras.substract_ranges([(1..10)], [(5..7)])).to eq [(1..4), (8..10)]
    end

    it 'should treat same numbers as intersection' do
      expect(MathExtras.substract_ranges([(1..1)], [(1..2)])).to eq []
      expect(MathExtras.substract_ranges([(2..2)], [(1..2)])).to eq []
      expect(MathExtras.substract_ranges([(2..3)], [(1..2), (3..4)])).to eq []
      expect(MathExtras.substract_ranges([(1..2), (2..3)], [(2..2)])).to eq [(1..1), (3..3)]
    end

    it 'should return array of lesser ranges if substracted ranges overlaps parts of given' do
      expect(MathExtras.substract_ranges([(1..10)], [(3..4), (7..12)])).to eq [(1..2), (5..6)]
      expect(MathExtras.substract_ranges([(7..25)], [(3..4), (8..12), (7..13), (20..24)])).to eq [(14..19), (25..25)]
      expect(MathExtras.substract_ranges([(6..25)], [(3..4), (8..12), (7..13), (20..24)])).to eq [(6..6), (14..19), (25..25)]
    end
  end

  describe '#start_with_consecutive' do
    it 'should drop numbers without enough consecutives' do
      array_of_numbers = [1,3,4,6,8,9,10,11,13,14,15,16]
      expect(MathExtras.start_with_consecutive(array_of_numbers, 3)).to eq [8,9,13,14]
    end

    it 'should find first fitting consecutive numbers' do
      array_of_numbers = [1,3,4,6,7,9,10,11,13]
      expect(MathExtras.start_with_consecutive(array_of_numbers, 2)).to eq [3,6,9,10]
      expect(MathExtras.start_with_consecutive(array_of_numbers, 3)).to eq [9]
    end

    it 'should return unchanged array for 1 or 0 consecutive' do
      array_of_numbers = [1,3,4,6,8,9,10,11,12]
      expect(MathExtras.start_with_consecutive(array_of_numbers, 1)).to eq array_of_numbers
      expect(MathExtras.start_with_consecutive(array_of_numbers, 0)).to eq array_of_numbers
    end

    it 'should return first number when just enough consecutive numbers' do
      array_of_numbers = [3,4,5]
      expect(MathExtras.start_with_consecutive(array_of_numbers, 3)).to eq [3]
    end

    it 'should return empty array if does not have enough consecutives' do
      array_of_numbers = [1,3,4,6,8,10,11,13]
      expect(MathExtras.start_with_consecutive(array_of_numbers, 3)).to eq []
      expect(MathExtras.start_with_consecutive([1,2], 3)).to eq []
    end

    it 'should handle unsorted array' do
      array_of_numbers = [1,3,4,6,8,9,10,11,13,14,15,16].shuffle
      expect(MathExtras.start_with_consecutive(array_of_numbers, 3)).to eq [8,9,13,14]
    end

    it 'should handle empty array' do
      array_of_numbers = []
      expect(MathExtras.start_with_consecutive(array_of_numbers, 3)).to eq []
    end
  end
end
