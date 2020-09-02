defmodule PlateslateWeb.Schema do
  use Absinthe.Schema

  alias Plateslate.Ordering.Order

  import_types(PlateslateWeb.Graphql.Types.Menu)
  import_types(PlateslateWeb.Graphql.Types.Category)
  import_types(PlateslateWeb.Graphql.Types.SearchResult)
  import_types(PlateslateWeb.Graphql.Types.MenuItemCreateResult)
  import_types(PlateslateWeb.Graphql.Types.OrderPlaceResult)

  import_types(PlateslateWeb.Graphql.InputTypes.OrderPlaceInput)
  import_types(PlateslateWeb.Graphql.InputTypes.MenuItemInput)

  query do
    import_fields(:menu_queries)
    import_fields(:search_queries)
  end

  mutation do
    import_fields(:menu_item_create)
    import_fields(:order_place)
    import_fields(:ready_order)
    import_fields(:complete_order)
  end

  subscription do
    field :new_order, :order do
      config(fn _args, _info ->
        {:ok, topic: "*"}
      end)
    end

    field :update_order, :order do
      arg(:id, non_null(:id))

      config(fn args, _info ->
        {:ok, topic: args.id}
      end)

      trigger([:ready_order, :complete_order],
        topic: fn
          order = %Order{} -> [order.id]
          _ -> []
        end
      )

      resolve(fn order = %Order{}, _, _ ->
        {:ok, order}
      end)
    end
  end

  object :menu_queries do
    field :menu_items, list_of(:menu_item), description: "The list of available menu items" do
      arg(:filter, non_null(:menu_item_filter))
      arg(:order, :sort_order, default_value: :asc)
      resolve(&Graphql.Resolvers.Menu.menu_items/3)
    end
  end

  object :search_queries do
    field :search, list_of(:search_result) do
      arg(:matching, non_null(:string))
      resolve(&Graphql.Resolvers.SearchResult.search/3)
    end
  end

  object :menu_item_create do
    field :menu_item_create, :menu_item_create_result do
      arg(:input, non_null(:menu_item_input))
      resolve(&Graphql.Resolvers.Menu.create_item/3)
    end
  end

  object :order_place do
    field :order_place, :order_place_result do
      arg(:input, non_null(:order_place_input))
      resolve(&Graphql.Resolvers.Ordering.order_place/3)
    end
  end

  object :ready_order do
    field :ready_order, :order_place_result do
      arg(:id, non_null(:id))
      resolve(&Graphql.Resolvers.Ordering.ready_order/3)
    end
  end

  object :complete_order do
    field :complete_order, :order_place_result do
      arg(:id, non_null(:id))
      resolve(&Graphql.Resolvers.Ordering.complete_order/3)
    end
  end
end
