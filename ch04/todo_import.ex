defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(), do: %TodoList{}

  def new(entries) do
    Enum.reduce(entries, %TodoList{}, &add_entry(&2, &1)) #fn entry, list_acc -> add_entry(list_acc, entry) end)
  end

  def add_entry(list, entry) do
    entry = Map.put(entry, :id, list.auto_id)

    new_entries = Map.put(list.entries, list.auto_id, entry)

    %TodoList{list | entries: new_entries, auto_id: list.auto_id + 1}
  end

  def update_entry(list, entry_id, updater_fn) do
    case Map.fetch(list.entries, entry_id) do
      :error ->
        list
      {:ok, old_entry} ->
        # ensure that its a map and id matches
        old_entry_id = old_entry.id

        # ^ gives us the value, not the var and then we set it equal
        # to the result of the update_fn, which in this case just returns
        # the new_entry, thus reassigning the old_enty_id to the new entry
        new_entry = %{id: ^old_entry_id} = updater_fn.(old_entry)

        # update entries collection, replacing the old_entry
        new_entries = Map.put(list.entries, new_entry.id, new_entry)

        # replace the list entries with the newly updated entries
        %TodoList{list | entries: new_entries}
    end
  end

  def update_entry(list, %{} = new_entry) do
    update_entry(list, new_entry.id, fn _ -> new_entry end)
  end

  def delete_entry(list, entry_id) do
    %TodoList{list | entries: Map.delete(list.entries, entry_id)}
  end

  def entries(list, date) do
    list.entries
    |> Stream.filter(fn {_id, entry} -> entry.date == date end)
    |> Enum.map(fn {_id, entry} -> entry end)
  end
end

defmodule TodoList.CsvImporter do
  def import(file_name \\ "todos.csv") do
    file_name
    |> read_lines
    |> create_entries
    |> TodoList.new()
  end

  defp read_lines(file_name) do
    file_name
    |> File.stream!
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  defp create_entries(lines) do
    lines
    |> Stream.map(&extract_fields/1)
    |> Enum.map(&create_entry/1)
  end

  defp extract_fields(line) do
    line
    |> String.split(",")
    |> convert_date()
  end

  defp create_entry({date, title}) do
    %{date: date, title: title}
  end

  defp convert_date([date_string, title]) do
    {parse_date(date_string), title}
  end

  defp parse_date(date_string) do
    [year, month, day] = date_string
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)

    {:ok, date} = Date.new(year, month, day)
    date
  end
end

