import Ecto.Query, only: [from: 2]

defmodule Server.APIController do
	use Server.Web, :controller

	def index(conn, _params) do
		json conn, %{status: "ok"}
	end

	def get_blocks(conn, _params) do
		json conn, %{status: "ok", blocks: [Server.BlockHelpers.genesis_block | Server.Repo.all(Server.Block)]}
	end

	def add_block_handler(conn, block) do
		{:ok, a} = Poison.encode(block)
		if Server.BlockHelpers.input_block_is_missing_params?(block) do
			if Server.BlockHelpers.block_is_valid?(block) do
				lastBlock = List.last([Server.BlockHelpers.genesis_block | Server.Repo.all(Server.Block)])
				if lastBlock.hash == block.prev_hash or lastBlock.status == 0 do
					Server.Repo.insert!(%Server.Block{
						from: block.from,
						to: block.to,
						value: block.value,
						prev_hash: block.prev_hash,
						comment: block.comment,
						nonce: 0,
						signature: block.signature,
						status: 0,
						hash: "",
						reward_to: ""
					})
					json conn, %{status: "ok"}
				else
					json conn, %{status: "error", error: "Invalid prevhash."}
				end
			else
				json conn, %{status: "error", error: "Invalid block."}
			end
		else
			json conn, %{status: "error", error: "Missing parameters."}
		end
	end

	def get_difficulty(conn, _params) do
		json conn, %{status: "ok", difficulty: Server.BlockHelpers.difficulty}
	end

	def add_block(conn, %{
		"block" => blockBaseStr
	}) do
		{:ok, blockStr} = Base.decode64(blockBaseStr)

		case Poison.decode(blockStr, as: Server.Block, keys: :atoms!) do
			{:ok, block} -> add_block_handler(conn, block)
			{:error, _} -> json conn, %{status: "error", error: "Invalid JSON."}
		end
	end

	def confirm_block(conn, %{
		"nonce" => nonceStr,
		"reward_to" => rewardToInput
	}) do
		{:ok, rewardTo} = Base.decode64(rewardToInput)
		{nonce, _} = Integer.parse(nonceStr)
		query = from b in Server.Block,
			where: b.status == 0,
			select: b
		blockToConfirm = Repo.all(query) |> List.first
		{hash, newBlock} = Server.BlockHelpers.calculate_hash(blockToConfirm, nonce)
		prefix = String.duplicate("0", Server.BlockHelpers.difficulty)
		if String.starts_with?(hash, prefix) do
			changeset = Server.Block.changeset(blockToConfirm, %{hash: hash, nonce: nonce, status: 1, reward_to: rewardTo})
			Server.Repo.update!(changeset)
			json conn, %{status: "ok"}
		else
			json conn, %{status: "error"}
		end
	end
end
