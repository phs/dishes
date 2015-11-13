action :use do
  prior_dish = (node.set['dishes']['dish'] ||= {})[new_resource.identity]
  new_dish = {
    'recipe' => new_resource.recipe,
    'wash_recipe' => new_resource.wash_recipe,
    'sink' => new_resource.sink
  }

  node.set['dishes']['dish'][new_resource.identity] = new_dish

  new_resource.updated_by_last_action(prior_dish != new_dish)
end

action :toss do
  was_present = (node.set['dishes']['dish'] ||= {}).key?(new_resource.identity)
  node.set['dishes']['dish'].delete(new_resource.identity)
  new_resource.updated_by_last_action(was_present)
end
