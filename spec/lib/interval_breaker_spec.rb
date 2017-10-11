require 'interval_breaker'

describe IntervalBreaker do
  describe "::break" do
    # 012345678
    #   aaaa
    # b
    it "ex1" do
      expect(IntervalBreaker.break([2,6], [0,1])).to eq [[2,6]]
    end
    # 012345678
    #   aaaa
    # bb
    it "ex2" do
      expect(IntervalBreaker.break([2,6], [0,2])).to eq [[2,6]]
    end
    # 012345678
    #   aaaa
    # bbb
    it "ex3" do
      expect(IntervalBreaker.break([2,6], [0,3])).to eq [[3,6]]
    end
    # 012345678
    #   aaaa
    #   bb
    it "ex4" do
      expect(IntervalBreaker.break([2,6], [2,4])).to eq [[4,6]]
    end
    # 012345678
    #   aaaa
    #    bb
    it "ex5" do
      expect(IntervalBreaker.break([2,6], [3,5])).to eq [[2,3], [5,6]]
    end
    # 012345678
    #   aaaa
    #    bbb
    it "ex6" do
      expect(IntervalBreaker.break([2,6], [3,6])).to eq [[2,3]]
    end
    # 012345678
    #   aaaa
    #     bbb
    it "ex7" do
      expect(IntervalBreaker.break([2,6], [3,7])).to eq [[2,3]]
    end
    # 012345678
    #   aaaa
    #       bb
    it "ex8" do
      expect(IntervalBreaker.break([2,6], [6,8])).to eq [[2,6]]
    end
    # 012345678
    #   aaaa
    #        b
    it "ex9" do
      expect(IntervalBreaker.break([2,6], [7,8])).to eq [[2,6]]
    end
    # 012345678
    #   aaaa
    # bbbbbbbbbb
    it "ex10" do
      expect(IntervalBreaker.break([2,6], [1,8])).to eq []
    end
  end

  describe "#conflicting_interval" do
    it "ex1" do
      expect(IntervalBreaker.conflicting_interval([1,2],[3,4])).to eq []
    end
    it "ex2" do
      expect(IntervalBreaker.conflicting_interval([3,4],[1,2])).to eq []
    end
    it "ex3" do
      expect(IntervalBreaker.conflicting_interval([1,3],[2,4])).to eq [2,3]
    end
    it "ex3" do
      expect(IntervalBreaker.conflicting_interval([1,1],[1,2])).to eq [1,1]
    end
    it "ex4" do
      expect(IntervalBreaker.conflicting_interval([1,1],[1,1])).to eq [1,1]
    end
  end
end
