defmodule Rectangle do
  def area({a, b}) do
    a * b
  end

  def area(a, b) do
    area({a, b})
  end
end