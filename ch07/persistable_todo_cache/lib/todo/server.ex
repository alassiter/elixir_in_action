defmodule Todo.Server do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
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
  def init(_) do
    {:ok, Todo.List.new()}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, current_list) do
    {:noreply, Todo.List.add_entry(current_list, new_entry)}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, updater_fn}, current_list) do
    {:noreply, Todo.List.update_entry(current_list, entry_id, updater_fn)}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, current_list) do
    {:noreply, Todo.List.delete_entry(current_list, entry_id)}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, current_list) do
    {:reply, Todo.List.entries(current_list, date), current_list}
  end
end
