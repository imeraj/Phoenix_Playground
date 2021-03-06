defmodule Plateslate.Ordering.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :customer_id, :integer
    field :ordered_at, :utc_datetime, read_after_writes: true
    field :state, :string, read_after_writes: true

    embeds_many :items, Plateslate.Ordering.Item

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:customer_id, :state])
    |> cast_embed(:items)
  end
end
