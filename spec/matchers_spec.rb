require 'spec_helper'

describe 'dishes custom matchers' do
  let(:name) { 'the-name' }
  let(:recipe) { 'dish_cookbook::dish_recipe' }
  let(:wash_recipe) { 'wash_cookbook::wash_recipe' }
  let(:sink) { 'the-sink' }

  let(:dish_chef_run) do
    ChefSpec::SoloRunner.new do |node|
      attrs = node.set['test_dishes']['dish_spec_recipe']
      attrs['name'] = name
      attrs['action'] = action
      attrs['recipe'] = recipe
      attrs['wash_recipe'] = wash_recipe
      attrs['sink'] = sink
    end.converge('test_dishes::dish_spec_recipe')
  end

  let(:sink_chef_run) do
    ChefSpec::SoloRunner.new do |node|
      attrs = node.set['test_dishes']['sink_spec_recipe']
      attrs['name'] = name
      attrs['action'] = action
      attrs['sink'] = sink
    end.converge('test_dishes::sink_spec_recipe')
  end

  describe 'use_dishes_dish' do
    let(:action) { :use }

    it 'can match' do
      expect(dish_chef_run).to use_dishes_dish(name).with(
        recipe: recipe,
        wash_recipe: wash_recipe,
        sink: sink
      )
    end
  end

  describe 'toss_dishes_dish' do
    let(:action) { :toss }

    it 'can match' do
      expect(dish_chef_run).to toss_dishes_dish(name).with(
        recipe: recipe,
        wash_recipe: wash_recipe,
        sink: sink
      )
    end
  end

  describe 'wash_dishes_sink' do
    let(:action) { :wash }

    it 'can match' do
      expect(sink_chef_run).to wash_dishes_sink(name).with(
        sink: sink
      )
    end
  end
end
