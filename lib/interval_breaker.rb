module IntervalBreaker
  #1. Sort the intervals based on increasing order of 
  #    starting time.
  #2. Push the first interval on to a stack.
  #3. For each interval do the following
  #   a. If the current interval does not overlap with the stack 
  #      top, push it.
  #   b. If the current interval overlaps with stack top and ending
  #      time of current interval is more than that of stack top, 
  #      update stack top with the ending  time of current interval.
  #4. At the end stack contains the merged intervals. 
  #
  
  def self.conflicting_interval(int1, int2)
    a, b = int1
    y, z = int2

    if (a <= y && b < y) || (z <= a && z < b)
      []
    else
      [a,b,y,z].sort[1..2]
    end
  end

  def self.break(int1, int2)
    a, b = int1
    y, z = int2

    if y <= a and z >= b
      []
    elsif z <= a or y >= b
      [ [a,b] ]
    elsif y <= a
      [ [z, b]]
    elsif y > a and z < b
      [ [a,y], [z, b] ]
    elsif y > a and z <= b
      [[a,y]]
    elsif y > a and z > b
      [[a,y]]
    end
  end
end
