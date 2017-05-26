defmodule Server.Block do
	use Ecto.Schema
	import Ecto.Changeset

	@derive {Poison.Encoder, only: [:from, :to, :value, :prev_hash, :comment, :nonce, :signature, :status, :hash, :reward_to]}

	schema "block" do
		field :from, :string
		field :to, :string
		field :value, :integer
		field :prev_hash, :string
		field :comment, :string
		field :nonce, :integer
		field :signature, :string
		field :status, :integer
		field :hash, :string
		field :reward_to, :string
	end

	def changeset(block, params \\ %{}) do
		block
		|> cast(params, [ :from, :to, :value, :prev_hash, :comment, :nonce, :signature, :status, :hash, :reward_to ])
	end
end

defmodule Server.BlockHelpers do
	def genesis_block do
		%Server.Block{
			from: "nothing",
			to: "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7hvWI+2x6Gz56vy6nJ2jM2rwbI062As+WUIDjYqIFmXyTwrtzzb5M1NeFcl7OA50lUqgYmNk7KqfR1zie1Y85kgssf5k3oHmnzsug9KiE7MrrZ0NyDci8EwIzEGBlJYFTXfja4iXWZCMW6LnqVXkSlUU2FreUCGNRentc8q2hiYcrZNLe4QIPFJwx4kydWZTvod4wh8NMMs7rOzE/5IUsRj+teW1i4BoyRdu9ncHiBUlduHC3osOjVqSv5WCZ73h61K8gsh+CB1d8MngVQy+nBjYqZ0LcZYr9bVHQ0lPaQoVcsw+ad5zJCQyY85Z7cKqSz6XtY4Gttl2inLYve58SwIDAQAB",
			value: 100,
			prev_hash: "nothing",
			comment: "",
			nonce: 318332,
			signature: "nothing",
			status: 1,
			hash: "00000CE7877F99BE802F305E33B65A60A4996771893AB5BA03C0B54F2BC7672D",
			reward_to: "nothing"
		}
	end

	def calculate_hash(blockInput, nonce) do
		block = %{
			from: blockInput.from,
			to: blockInput.to,
			value: blockInput.value,
			prev_hash: blockInput.prev_hash,
			comment: blockInput.comment,
			nonce: nonce,
			status: 0,
			signature: blockInput.signature,
			reward_to: ""
		}
		{_, blockToHash} = Map.pop(block, :hash)
		{:ok, encoded} = Poison.encode(blockToHash)
		{ :crypto.hash(:sha256, encoded) |> Base.encode16(), block }
	end

	def difficulty do
		5
	end

	def block_is_missing_params?(%{
			from: from,
			to: to,
			value: value,
			prev_hash: prev_hash,
			comment: comment,
			nonce: nonce,
			signature: signature,
			status: status,
			hash: hash,
			reward_to: reward_to
		}) do
		from != nil && 
		to != nil && 
		value != nil && 
		prev_hash != nil && 
		comment != nil && 
		nonce != nil && 
		signature != nil && 
		status != nil && 
		hash != nil && 
		reward_to != nil
	end

	def block_is_missing_params?(_) do
		false
	end

	def input_block_is_missing_params?(%{
			from: from,
			to: to,
			value: value,
			prev_hash: prev_hash,
			comment: comment
		}) do
		from != nil && 
		to != nil && 
		value != nil && 
		prev_hash != nil && 
		comment != nil
	end

	def input_block_is_missing_params?(_) do
		false
	end

	def block_is_valid?(block) do
		key = Server.Address.get_public_key_from_address(block.from)
		blockToSign = %{
			from: block.from,
			to: block.to,
			value: block.value,
			comment: block.comment,
			prev_hash: block.prev_hash
		}
		{:ok, blockStr} = Poison.encode(blockToSign)
		{:ok, signature} = block.signature |> Base.decode16()

		{:ok, valid} = RsaEx.verify(blockStr, signature, key)
		valid
	end
end