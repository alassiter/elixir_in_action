defmodule MultiDict do
  def new(), do: %{}
  
  def add(dict, key, value) do
    Map.update(dict, key, [value], &[value | &1])
  end

  def get(dict, key) do
    Map.get(dict, key, [])
  end
end

defmodule TodoList do
  require MultiDict

  def new(), do: MultiDict.new()

  def add_entry(list, entry) do
    MultiDict.add(list, entry.date, entry)
  end

  def entries(list), do: list

  def entries(list, date) do
    MultiDict.get(list, date)
  end
end
