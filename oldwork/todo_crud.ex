defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(), do: %TodoList{}

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
