defmodule Geometry do
  @pi 3.14

  def area({:rectangle, a, b}) do
    a * b
  end

  def area({:square, a}) do
    a * a
  end

  def area({:circle, radius}) do
    radius * radius * @pi
  end

  def area(unknown) do
    {:error, {:unknown_shape, unknown}}
  end
end