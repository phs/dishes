attrs = node['test_dishes']['dish_spec_recipe']

dishes_dish attrs['name'] do
  action attrs['action'] if attrs.key?('action')
  recipe attrs['recipe'] if attrs.key?('recipe')
  wash_recipe attrs['wash_recipe'] if attrs.key?('wash_recipe')
  sink attrs['sink'] if attrs.key?('sink')
end
