defmodule TodoServer do
  def start() do
    spawn(fn ->
      Process.register(self(), :todo_server)
      loop(TodoList.new())
    end)
  end

  def add_entry(new_entry) do
    send(:todo_server, {:add_entry, new_entry})
  end

  def update_entry(entry) do
    send(:todo_server, {:update_entry, entry})
  end

  def delete_entry(entry_id) do
    send(:todo_server, {:delete_entry, entry_id})
  end

  def entries() do
    send(:todo_server, {:entries, self()})
    receive do
      {:response, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  def entries(date) do
    send(:todo_server, {:entries, self(), date})
    receive do
      {:response, entries} -> entries
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

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:update_entry, entry}) do
    TodoList.update_entry(todo_list, entry)
  end

  defp process_message(todo_list, {:delete_entry, entry_id}) do
    TodoList.delete_entry(todo_list, entry_id)
  end

  defp process_message(todo_list, {:entries, caller}) do
    send(caller, {:response, todo_list.entries})
    todo_list
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:response, TodoList.entries(todo_list, date)})
    todo_list # <----- this is needed b/c the server uses as the new state
  end
end

#############################################
# TodoList
#############################################
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




