defmodule MultiDict do
  def new(), do: %{}

  def add(dict, key, value) do
    Map.update(dict, key, [value], &[value | &1]) # fn values -> [value | values] end
  end

  def get(dict, key) do
    Map.get(dict, key, [])
  end
end

defmodule TodoList do
  def new(), do: MultiDict.new()

  def add_entry(list, entry) do
    MultiDict.add(list, entry.date, entry)
  end

  def entries(list, date) do
    MultiDict.get(list, date)
  end

  def due_today(list) do
    MultiDict.get(list, Date.utc_today)
  end
end
