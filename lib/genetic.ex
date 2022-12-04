defmodule Genetic do
  @moduledoc """
  Documentation for `Genetic`.
  """
  alias Types.Chromosome

  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    for _ <- 1..population_size, do: genotype.()
  end

  def evaluate(population, fitness_function, opts \\ []) do
    population
    |> Enum.map(
      fn chromosome ->
        fitness = fitness_function.(chromosome)
        age = chromosome.age + 1
        %Chromosome{chromosome | fitness: fitness, age: age}
      end)
    |> Enum.sort_by(& &1.fitness, &>=/2)
  end

  def select(population, opts \\ []) do
    select_fn = Keyword.get(opts, :selection_type, Toolbox.Selection.elite/2)
    slect_rate = Keyword.get(opts, :selection_rate, 0.8)

    n = round(length(population) * selection_rate)
    n = if rem(n, 2) == 0, do: n, else: n+1
    parents =
      select_fn
        |> apply([population, n])

    leftover =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(parents))

    {parents, MapSet.to_list(leftover)}
  end

  def crossover(population, opts \\ []) do
    population
    |> Enum.reduce([],
      fn {p1, p2}, acc ->
        cx_point = :rand.uniform(length(p1.genes))
        {{h1, t1}, {h2, t2}} =
          {Enum.split(p1.genes, cx_point),
          Enum.split(p2.genes, cx_point)}
        {c1, c2} =
          {%Chromosome{p1 | genes: h1 ++ t2},
          %Chromosome{p2 | genes: h2 ++ t1}}
        [c1, c2 | acc]
      end)
  end

  def mutation(population, opts \\ []) do
    population
    |> Enum.map(
      fn chromosome ->
        if :rand.uniform() < 0.05 do
          %Chromosome{chromosome | genes: Enum.shuffle(chromosome.genes)}
          chromosome
        else
          chromosome
        end
      end)
  end

  def run(problem, opts \\ []) do
    population = initialize(&problem.genotype/0, opts)
    population
    |> evolve(problem, 0, opts)
  end

  def evolve(population, problem, generation, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/1, opts)
    best = hd(population)
    best_fitness = best.fitness
    IO.write("\rCurrent best: #{best.fitness}")
    if problem.terminate?(population, generation) do
      best
    else
      {parents, leftover} = select(population, opts)
      children = crossover(parents, opts)
      children ++ leftover
      |> mutation(opts)
      |> evolve(problem, generation+1, opts)
    end
  end

end
