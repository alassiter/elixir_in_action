defmodule Todo.List do
  defstruct auto_id: 1, entries: %{}

  def new(), do: %Todo.List{}

  def new(entries) do
    Enum.reduce(
      entries,
      %Todo.List{},

      #fn entry, list_acc -> add_entry(list_acc, entry) end)
      &add_entry(&2, &1)
    )
  end

  def add_entry(list, entry) do
    # Add id to the entry
    entry = Map.put(entry, :id, list.auto_id)

    # Add entry to the list of entries
    new_entries = Map.put(list.entries, list.auto_id, entry)

    # Return a new list with the new entries and incr auto_id
    %Todo.List{list | entries: new_entries, auto_id: list.auto_id + 1}
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
        %Todo.List{list | entries: new_entries}
    end
  end

  def update_entry(list, %{} = new_entry) do
    update_entry(list, new_entry.id, fn _ -> new_entry end)
  end

  def delete_entry(list, entry_id) do
    %Todo.List{list | entries: Map.delete(list.entries, entry_id)}
  end

  def entries(list, date) do
    list.entries
    |> Stream.filter(fn {_id, entry} -> entry.date == date end)
    |> Enum.map(fn {_id, entry} -> entry end)
  end
end
