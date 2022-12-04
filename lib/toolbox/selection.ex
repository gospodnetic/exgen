defmodule Toolbox.Selection do
  def elite(population, n) do
  population
    |> Enum.take(n)
  end

  def random(population, n) do
    population
    |> Enum.take_random(n)
  end

  def tournament(population, n, tourn_size) do
    0..n-1
    |> Enum.map(fn _ ->
      population
      |> Enum.take_random(tournsize)
      |> Enum.max_by(&(^1.fitness))
    end)
  end

  def roulette(population, n) do
    sum_fitness =
      population
      |> Enum.map(&(&1.fitness))
      |> Enum.sum()

    0..n-1
      |> Enum.map(fn _ ->
        u = :rand.uniform() * sum_fitness

        population
        |> Enum.reduce_while(0, fn x, sum ->
          if x.fitness + sum > u do
            {:halt, x}
          else
            {:cont, x.fitness + sum}
        end)
      end)
  end

  def tournament_no_duplicates(population, n, tourn_size) do
    selected = MapSet.new()
    tournament_helper(population, n, tourn_size, selected)
  end

  defp tournament_helper(population, n, tourn_size, selected) do
    if MapSet.size(selected) == n do
      MapSet.to_list(selected)
    else
      chosen = population
        |> Enum.take_random(tourn_size)
        |> Enum.max_by(&(&1.fitness))
      tournament_helper(population, n, tourn_size, MapSet.put(selected, chosen))
  end
end
