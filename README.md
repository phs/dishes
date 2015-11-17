# dishes #

Chef cookbook to clean up recipes after removal

## Motivation ##

Chef does not generally support an "undo" feature for recipes.  Once one executes, there isn't an easy way to return a node to it's pre-recipe state.  To solve the problem systematically looks rather hard, so Chef is perhaps wise not to try.  There is however at least one scenario where a feasible, limited "undo" would be very helpful.

A recurring problem that can afflict distributed services is the [_split brain_ scenario][split-brain-wikipedia].  Though it can emerge in many different contexts, a common cause is that some daemon is running unexpectedly when we would really prefer it to be off.

The "right" way to avoid split brains caused this way is of course to ensure that the offending daemon is turned off to start with.  However if the daemon is managed with Chef then this can be difficult.  Particularly in a bare-metal cluster with long-lived nodes, a node's run list may evolve over time and the recipe controlling the daemon might be removed.  (A cluster running in a cloud environment would be better served by destroying and recreating the nodes, avoiding the evolving run lists completely.)  An unwary administrator might see later that the node does not have the service in its run list and assume the daemon is not installed (let alone running.)

Chef itself does not offer a way to cleanup removed entries from a run list as a first class feature, perhaps because we can emulate this ourselves.  For example, one can imagine our administrator adding a `disable_service_daemon` "cleanup" recipe to the node at the same time that the original daemon recipe is removed.

That works, but it requires that the clean up recipe exists and that the administrator is aware of the issue and so can take action.  This however scales poorly: consider that the offending daemons might be brought as transitive cookbook dependencies.  It would better if Chef could do this for us.

It turns out that it can, with some help.  This cookbook supplies two LWRPs named `dishes_dish` and `dishes_sink`, which work together to enable Chef (and recipe authors) to react to recipes removed from a run list by including corresponding "cleanup" recipes.

[split-brain-wikipedia]: https://en.wikipedia.org/wiki/Split-brain_(computing)

## Usage ##

```ruby
# Tell dishes_sink to include `disable_daemon` if `daemon` is not in the run list
dishes_dish 'cookbook::daemon' do
  action :use
  wash_recipe 'cookbook::disable_daemon'
  sink 'default'
end

# Include the wash recipes of all dishes whose recipe is not in the run list
dishes_sink 'default'
```

In this example, the `cookbook::daemon` recipe uses a dish.  The dish declares that when `cookbook::daemon` vanishes from the run list, the `dishes_sink` should respond by including the `cookbook::disable_daemon` recipe.

One attaches a cleanup (or "wash") recipe to a monitored recipe with `dishes_dish`.  The association is kept in a hidden normal attribute and thus lives in the state of the Chef server.  Nothing is saved on the node itself.  Each recipe that needs cleanup actions should use a dish.

A recipe is allowed to use its _own_ dish, allowing cookbooks to clean up after themselves (but see below about sinks) however it is not required.  Dishes and corrosponding wash recipes can also live in a wrapper cookbook.  In our example above, the `dishes_dish` and `dishes_sink` resources might live in `wrapper_cookbook::install_daemon`.

Dishes themselves do not take action, they just keep the books.  To actually wash the dirty dishes, one needs a `dishes_sink`.  A sink is a labeled bag of dishes.  Like dishes, sinks do not represent any aspect of the node, and are in fact stateless.  Dishes choose what sink they are placed in.

When the `dishes_sink` runs, it examines the Chef server's attribute state to see what dishes have been placed into it, now or in the past.  It then examines each and if a dish is deemed "dirty" (its naming recipe is absent from the run list) the sink will `include_recipe` the corrosponding `wash_recipe`, thereby "washing" it.  Dishes whose wash recipe is already present in the run list are considered clean.

While dishes leave traces of themselves behind in the Chef server, sinks do not.  Therefore if the recipe containing `dishes_sink` is removed, nothing gets clean.  Though one might imagine a dedicated service to wash the dirty dishes even if the sink recipe is absent, this is currently out of scope.

## Requirements ##

Chef 11+

## Resources/Providers ##

### `dishes_dish` ###

An LWRP that associates a `wash_recipe` with a given `recipe` via attributes in the Chef server.

#### Actions ####
* `:use`: Associate the `wash_recipe` with the `recipe` (default).
* `:toss`: Discard any existing association.

#### Parameters ####
* `recipe`: The recipe to monitor in the run list (name attribute).
* `wash_recipe`: The recipe to include if `recipe` vanishes from the run list (required).
* `sink`: The sink to place this dish in (default: `default`).

### `dishes_sink` ###

An LWRP to wash dirty `dishes_dish`s.

#### Actions ####
* `:wash`: Include the `wash_recipes` of any `dishes_dish` placed in the named sink, now or in the past (default).

#### Parameters ####
* `sink`: The sink to wash (name attribute, typically `default`).

## Development ##

Fork, use feature branches.  Add new `chefspec` and `test-kitchen` tests as warranted. Open PRs.

## License ##

MIT.  See LICENSE
