class MathExtras
  # substract array of intrger ranges from array of intrger ranges
  # ranges can be arrays [start, end]
  def self.substract_ranges(given_ranges, substracted_ranges)
    substracted_ranges.each do |substracted|
      eliminated_ranges = []
      lesser_ranges = []

      given_ranges.each do |given|
        if substracted.first <= given.last && substracted.last >= given.first
          eliminated_ranges << given

          if substracted.first <= given.first && substracted.last >= given.last
            # fully eliminated range
            next
          elsif substracted.first <= given.first && substracted.last <= given.last
            # cut beginning of range
            lesser_ranges << (substracted.last.next..given.last)
          elsif substracted.first >= given.first && substracted.last >= given.last
            # cut ending of range
            lesser_ranges << (given.first..substracted.first.pred)
          elsif substracted.first >= given.first && substracted.last <= given.last
            # cut middle of range
            lesser_ranges << (given.first..substracted.first.pred)
            lesser_ranges << (substracted.last.next..given.last)
          end
        end
      end

      given_ranges = given_ranges - eliminated_ranges + lesser_ranges

      break if given_ranges.length == 0
    end

    given_ranges
  end

  # takes array of numers and returns numbers which had enough consecutive numbers folowing them
  def self.start_with_consecutive(array_of_numbers, number_of_consecutive)
    return array_of_numbers if number_of_consecutive <= 1
    return [] if array_of_numbers.size < number_of_consecutive

    array_of_numbers = array_of_numbers.sort
    result = []

    (array_of_numbers.first..array_of_numbers.last).each do |number|
      next unless array_of_numbers.index(number)

      starting_index = array_of_numbers.index(number)
      ending_index = starting_index + number_of_consecutive - 1

      break unless array_of_numbers[ending_index]

      if array_of_numbers[ending_index] - array_of_numbers[starting_index] ==
          number_of_consecutive - 1
        result << number
      end
    end

    result
  end
end
