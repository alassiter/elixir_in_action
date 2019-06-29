defmodule Streams do
  def filtered_lines!(path) do
    File.stream!(path)
    |> Stream.map(&strip_line/1)
  end

  def large_lines!(path) do
    filtered_lines!(path)
    |> Enum.filter(&(String.length(&1) > 20))
  end

  def line_lengths!(path) do
    filtered_lines!(path)
    |> Enum.map(&String.length/1)
  end

  def longest_line_length!(path) do
    filtered_lines!(path)
    |> Stream.map(&String.length/1)
    |> Enum.max()
  end

  def longest_line!(path) do
    filtered_lines!(path)
    |> Stream.filter(&(String.length(&1) == longest_line_length!(path)))
    |> Enum.at(0)
  end

  def words_per_line!(path) do
    filtered_lines!(path)
    |> Enum.map(&word_count/1)
  end

  defp word_count(string) do
    string
    |> String.split()
    |> length()
  end

  defp strip_line(line) do
    String.replace(line, "\n", "")
  end
end
