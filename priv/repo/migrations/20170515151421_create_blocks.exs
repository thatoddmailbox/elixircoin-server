defmodule Server.Repo.Migrations.CreateBlocks do
  use Ecto.Migration

  def change do
    create table(:block) do
      add :from, :string
      add :to, :string
      add :value, :integer
      add :prev_hash, :string
      add :comment, :string
      add :nonce, :integer
      add :signature, :string
      add :status, :integer
      add :hash, :string
      add :reward_to, :string
    end
  end
end
