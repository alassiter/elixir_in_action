defmodule Todo.Server do
  use GenServer

  def start(name) do
    GenServer.start(__MODULE__, name)
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def update_entry(todo_server, entry_id, updater_fn) do
    GenServer.cast(todo_server, {:update_entry, entry_id, updater_fn})
  end

  def delete_entry(todo_server, entry_id) do
    GenServer.cast(todo_server, {:delete_entry, entry_id})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  @impl GenServer
  def init(name) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new()}}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, current_list}) do
    new_list = Todo.List.add_entry(current_list, new_entry)
    Todo.Database.store(name, new_list)

    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, updater_fn}, {name, current_list}) do
    new_list = Todo.List.update_entry(current_list, entry_id, updater_fn)
    Todo.Database.store(name, new_list)

    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, {name, current_list}) do
    new_list = Todo.List.delete_entry(current_list, entry_id)
    Todo.Database.store(name, new_list)

    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, {name, current_list}) do
    {
      :reply,
      Todo.List.entries(current_list, date),
      {name, current_list}
    }
  end
end
