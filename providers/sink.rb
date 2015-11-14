action :wash do
  dishes = (node.set['dishes']['dish'] ||= {})

  washable_dishes = dishes.values.select do |dish|
    new_resource.sink == dish['sink'] &&
    !node.recipe?(dish['recipe']) &&
    !node.recipe?(dish['wash_recipe'])
  end

  washable_dishes.each do |dish|
    run_context.include_recipe dish['wash_recipe']
  end

  new_resource.updated_by_last_action(washable_dishes.any?)
end
