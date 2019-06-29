defmodule ListHelper do
  def sum(list) do
    do_sum(0, list)
  end

  def len(list), do: len(0, list)

  def len(current_len, []), do: current_len
  def len(current_len, [_head | tail]) do
    # given [1,2,3] should get 3
    len(current_len + 1, tail)
  end

  defp do_sum(current_sum, []) do
    current_sum
  end

  defp do_sum(current_sum, [head | tail]) do
    head + current_sum
    |> do_sum(tail)
  end
end
