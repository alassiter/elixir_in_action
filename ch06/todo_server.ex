defmodule TodoServer do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def add_entry(new_entry) do
    GenServer.cast(__MODULE__, {:add_entry, new_entry})
  end

  def update_entry(entry_id, updater_fn) do
    GenServer.cast(__MODULE__, {:update_entry, entry_id, updater_fn})
  end

  def delete_entry(entry_id) do
    GenServer.cast(__MODULE__, {:delete_entry, entry_id})
  end

  def entries(date) do
    GenServer.call(__MODULE__, {:entries, date})
  end

  @impl GenServer
  def init(_) do
    {:ok, TodoList.new()}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, current_list) do
    {:noreply, TodoList.add_entry(current_list, new_entry)}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, updater_fn}, current_list) do
    {:noreply, TodoList.update_entry(current_list, entry_id, updater_fn)}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, current_list) do
    {:noreply, TodoList.delete_entry(current_list, entry_id)}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, current_list) do
    {:reply, TodoList.entries(current_list, date), current_list}
  end
end

defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(), do: %TodoList{}

  def new(entries) do
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
