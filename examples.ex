# Pure functional, must pass the new value to the next call
list = TodoList.new() |>
  TodoList.add_entry(%{date: ~D[2018-01-01], task: "Shopping"}) |>
  TodoList.add_entry(%{date: ~D[2018-01-02], task: "Movie"}) |>
  TodoList.add_entry(%{date: ~D[2018-01-03], task: "Dinner"})

TodoList.entries(list, ~D[2018-01-01])

TodoList.update_entry(list, 1, fn old_entry -> Map.put(old_entry, :task, "Drive Home") end)

TodoList.update_entry(list, %{id: 1, task: "Drive Home"})

TodoList.delete_entry(list, 4)

entries = [
  %{date: ~D[2018-12-19], title: "Dentist"},
  %{date: ~D[2018-12-20], title: "Shopping"},
  %{date: ~D[2018-12-19], title: "Movies"},
]

TodoList.CsvImporter.import("todos.csv")

# TodoServer version
todo_server = TodoServer.start()
TodoServer.add_entry(%{date: ~D[2018-01-01], task: "Shopping"})
TodoServer.add_entry(%{date: ~D[2018-01-02], task: "Movie"})
TodoServer.add_entry(%{date: ~D[2018-01-03], task: "Dinner"})

TodoServer.entries(~D[2018-01-01])

TodoServer.update_entry(todo_server, %{id: 1, task: "Drive Home"})

TodoServer.delete_entry(todo_server, 2)

# Calculator
calc = Calculator.start()
Calculator.add(calc, 4)
Calculator.add(calc, 40)
Calculator.sub(calc, 10)
Calculator.mul(calc, 5)
Calculator.div(calc, 2)
Calculator.value(calc)
