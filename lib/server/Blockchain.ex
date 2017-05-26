defmodule Server.Blockchain do
  def calculate_balance_from_blocks(address, [block | remainder], balance \\ 0) do
    0
  end

  def calculate_balance_from_blocks(address, [], balance) do
    balance
  end
end