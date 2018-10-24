defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(), do: %TodoList{}

  def new(entries) do
    Enum.reduce(
      entries,
      %TodoList{},
      fn entry, todo_list_acc ->
        add_entry(todo_list_acc, entry)
      end
    )
  end

  def add_entry(list, entry) do
    entry = Map.put(entry, :id, list.auto_id)

    new_entries = Map.put(list.entries, list.auto_id, entry)

    %TodoList{list | entries: new_entries, auto_id: list.auto_id + 1}
  end

  def entries(list, date) do
    list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(list, %{} = new_entry) do
    update_entry(list, new_entry.id, fn _ -> new_entry end)
  end

  def update_entry(list, id, updater_fn) do
    case Map.fetch(list.entries, id) do
      :error ->
        list

      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fn.(old_entry)
        new_entries = Map.put(list.entries, new_entry.id, new_entry)
        %TodoList{list | entries: new_entries}
    end
  end

  def delete_entry(list, entry_id) do
    %TodoList{list | entries: Map.delete(list.entries, entry_id)}
  end
end

defmodule TodoList.CsvImporter do
  def import(file) do
    file
    |> read_lines()
    |> create_entries()
    |> TodoList.new()
  end

  def read_lines(file) do
    file
    |> File.stream!()
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  def create_entries(lines) do
    lines
    |> Stream.map(&extract_fields/1)
    |> Stream.map(&create_entry/1)
  end

  def extract_fields(line) do
    line
    |> String.split(",")
    |> create_date()
  end

  def create_date([date, task]) do
    {parse_date(date), task}
  end

  def parse_date(date) do
    [year, month, day] =
      date
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)

    {:ok, date} = Date.new(year, month, day)
    date
  end

  def create_entry({date, task}) do
    %{date: date, task: task}
  end
end




