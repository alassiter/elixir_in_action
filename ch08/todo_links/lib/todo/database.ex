defmodule Todo.Database do
  use GenServer

  # Compile time constant
  @db_folder "./persist"

  def start_link do
    IO.puts("Starting database.")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  def list_workers do
    GenServer.call(__MODULE__, {:list_workers})
  end

  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@db_folder)

    # Results is %{0 => <pid>, 1 => <pid>, ...}
    {:ok, start_workers()}
  end

  @impl GenServer
  def handle_call({:list_workers}, _, database_workers) do
    {:reply, database_workers, database_workers}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _, database_workers) do
    worker = :erlang.phash(key, 3)

    {:reply, database_workers[worker], database_workers}
  end

  defp start_workers() do
    for index <- 1..3, into: %{} do
      {:ok, pid} = Todo.DatabaseWorker.start_link(@db_folder)
      {index - 1, pid}
    end
  end
end
