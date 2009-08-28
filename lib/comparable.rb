module Comparable
  def not_below(mn)
    self < mn ? mn : self
    end
  def not_above(mx)
    self > mx ? mx : self
    end
  def not_outside(mn,mx)
    mn,mx = mx,mn if mx < mn
    self.not_below(mn).not_above(mx)
    end
  end
