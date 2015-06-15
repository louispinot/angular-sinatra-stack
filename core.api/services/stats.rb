module Stats
  def quantile(p)
    values = self
    return nil if values.empty?
    return values.first if values.size == 1
    values.sort!
    return values.last if p == 1
    rank = p * (values.size - 1)
    lower, upper = values[rank.floor, 2]
    lower + (upper - lower) * (rank - rank.floor)
  end

  def quantile_of_score(score)
    values = self
    values.sort!
    i = values.rindex(score)
    return 1 if i == (values.length-1)
    (i.to_f/(values.length - 1).to_f)
  end
end

class Array
  include Stats
end
