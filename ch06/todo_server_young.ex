defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})

    receive do
      {:response, response} ->
        response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} = callback_module.handle_call(request, current_state)
        send(caller, {:response, response})
        loop(callback_module, new_state)

      {:cast, request} ->
        new_state = callback_module.handle_cast(request, current_state)
        loop(callback_module, new_state)
    end
  end
end

defmodule TodoServer do
  def start do
    ServerProcess.start(TodoServer)
  end

  def add_entry(pid, new_entry) do
    ServerProcess.cast(pid, {:add_entry, new_entry})
  end

  def update_entry(pid, entry_id, updater_fn) do
    ServerProcess.cast(pid, {:update_entry, entry_id, updater_fn})
  end

  def delete_entry(pid, entry_id) do
    ServerProcess.cast(pid, {:delete_entry, entry_id})
  end

  def entries(pid, date) do
    ServerProcess.call(pid, {:entries, date})
  end

  def init do
    TodoList.new()
  end

  def handle_cast({:add_entry, new_entry}, current_list) do
    TodoList.add_entry(current_list, new_entry)
  end

  def handle_cast({:update_entry, entry_id, updater_fn}, current_list) do
    TodoList.update_entry(current_list, entry_id, updater_fn)
  end

  def handle_cast({:delete_entry, entry_id}, current_list) do
    TodoList.delete_entry(current_list, entry_id)
  end

  def handle_call({:entries, date}, current_list) do
    {TodoList.entries(current_list, date), current_list}
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
