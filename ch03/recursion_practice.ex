defmodule RecursionPractice do
  def range(from, to) when from > to, do: []
  def range(from, to) do
    # (2,5) => [2,3,4,5]
    # (5,2) => []
    # [2,2] => [2]
    [from | range(from + 1, to)]
  end
end
