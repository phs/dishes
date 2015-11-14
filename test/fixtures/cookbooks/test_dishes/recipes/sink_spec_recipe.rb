attrs = node['test_dishes']['sink_spec_recipe']

dishes_sink attrs['name'] do
  action attrs['action'] if attrs.key?('action')
  sink attrs['sink'] if attrs.key?('sink')
end
