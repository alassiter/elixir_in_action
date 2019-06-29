defmodule NaturalNums do
  def print(1), do: IO.puts(1)
  def print(x) when x < 1, do: {:error, "number must be positive"}
  def print(x) when is_float(x), do: {:error, "number must be an integer"}
  def print(x) when not is_number(x), do: {:error, "must be a number"} 
  def print(n) do
    print(n - 1)
    IO.puts(n)
  end
end
