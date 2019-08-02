defmodule TodoServer do
  def start do
    spawn(fn ->
      Process.register(self(), :todo_server)
      loop(TodoList.new())
    end)
  end

  def add_entry(new_entry) do
    send(:todo_server, {:add_entry, new_entry})
  end

  def update_entry(entry_id, updater_fn) do
    send(:todo_server, {:update_entry, entry_id, updater_fn})
  end

  def delete_entry(entry_id) do
    send(:todo_server, {:delete_entry, entry_id})
  end

  def entries(date) do
    send(:todo_server, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
        message -> process_message(todo_list, message)
      end

    loop(new_todo_list)
  end

  defp process_message(current_list, {:add_entry, new_entry}) do
    TodoList.add_entry(current_list, new_entry)
  end

  defp process_message(current_list, {:update_entry, entry_id, updater_fn}) do
    TodoList.update_entry(current_list, entry_id, updater_fn)
  end

  defp process_message(current_list, {:delete_entry, entry_id}) do
    TodoList.delete_entry(current_list, entry_id)
  end

  defp process_message(current_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(current_list, date)})
    current_list # needed b/c the loop uses this to set the new state!
  end
end

defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(), do: %TodoList{}

  def new(entries \\ []) do
    Enum.reduce(entries, %TodoList{}, &add_entry(&2, &1)) #fn entry, list_acc -> add_entry(list_acc, entry) end)
  end

  def add_entry(list, entry) do
    # Add id to the entry
    entry = Map.put(entry, :id, list.auto_id)

    # Add entry to the list of entries
    new_entries = Map.put(list.entries, list.auto_id, entry)

    # Return a new list with the new entries and incr auto_id
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
