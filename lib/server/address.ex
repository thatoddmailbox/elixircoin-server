defmodule Server.Address do
  def get_public_key_from_address(address) do
    addressParts = address |> String.codepoints |> Enum.chunk(64, 64, []) |> Enum.map(&Enum.join(&1)) 
    Enum.concat([ "-----BEGIN PUBLIC KEY-----" ], addressParts) |> Enum.concat([ "-----END PUBLIC KEY-----", "" ]) |> Enum.join("\n")
  end
end