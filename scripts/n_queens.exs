defmodule NQueens do
  @behaviour Problem
  alias Types.Chromosome

  def genotype do
    genes = Enum.shuffle(0..7)
    %Chromosome{genes: genes, size: 8}
  end

  def fitness_function(chromosome) do
    diag_clashes =
      for i <- 0..7, j <- 0..7 do
        if i != j do
          # horizontal distance
          dx = abs(i - j)
          # vertical distance
          abs()
        else
          # The same field
          0
      end
  end
end
