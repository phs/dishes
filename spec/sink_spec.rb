require 'spec_helper'

describe 'dishes::sink' do
  # let(:server_runner) { ChefSpec::ServerRunner.new step_into: 'dishes_sink' }
  let(:name) { 'the-name' }
  let(:calling_recipe) { 'test_dishes::sink_spec_recipe' }
  let(:action) { :wash }
  let(:sink) { 'the-sink' }
  let(:different_sink) { 'different-sink' }

  let(:first_dish_recipe) { 'test_dishes::first_dish_recipe' }
  let(:first_wash_recipe) { 'test_dishes::first_wash_recipe' }
  let(:first_dish_sink) { sink }

  let(:second_dish_recipe) { 'test_dishes::second_dish_recipe' }
  let(:second_wash_recipe) { 'test_dishes::second_wash_recipe' }
  let(:second_dish_sink) { sink }

  let(:dishes) do
    {
      'first-dish' => {
        'recipe' => first_dish_recipe,
        'wash_recipe' => first_wash_recipe,
        'sink' => first_dish_sink
      },
      'second-dish' => {
        'recipe' => second_dish_recipe,
        'wash_recipe' => second_wash_recipe,
        'sink' => second_dish_sink
      }
    }
  end

  let(:explicit_run_list) { [calling_recipe] }

  let(:chef_run) do
    ChefSpec::ServerRunner.new step_into: 'dishes_sink' do |node|
      attrs = {}
      attrs['name'] = name if name
      attrs['action'] = action if action
      attrs['sink'] = sink if sink

      node.set['test_dishes']['sink_spec_recipe'] = attrs

      node.set['dishes']['dish'] = dishes if dishes
    end.converge(*explicit_run_list)
  end

  it 'runs' do
    chef_run
  end

  let(:resource) { chef_run.find_resource(:dishes_sink, name) }

  describe 'without a sink attribute' do
    let(:sink) { nil }

    it 'assumes the name' do
      expect(resource.sink).to eq(name)
    end
  end

  describe 'with action :wash' do
    let(:action) { :wash }
    let(:wash_recipes) { [] }

    shared_examples_for 'an empty sink' do
      it 'includes nothing' do
        expect(chef_run.node.recipes).to eq(explicit_run_list)
      end

      it 'is not updated by the last action' do
        expect(resource).to_not be_updated_by_last_action
      end
    end

    shared_examples_for 'a full sink' do
      it 'includes the wash recipes of dirty dishes' do
        wash_recipes.each do |wash_recipe|
          expect(chef_run).to include_recipe(wash_recipe)
        end
      end

      it 'is updated by the last action' do
        expect(resource).to be_updated_by_last_action
      end
    end

    describe 'with no dishes' do
      let(:dishes) { nil }
      it_should_behave_like 'an empty sink'
    end

    describe 'with dirty dishes' do
      let(:wash_recipes) { [first_wash_recipe, second_wash_recipe] }
      it_should_behave_like 'a full sink'
    end

    describe 'with dirty dishes in a different sink' do
      let(:first_dish_sink) { different_sink }
      let(:second_dish_sink) { different_sink }
      it_should_behave_like 'an empty sink'
    end

    describe 'with dirty dishes in many sinks' do
      let(:second_dish_sink) { different_sink }
      let(:wash_recipes) { [first_wash_recipe] }
      it_should_behave_like 'a full sink'
    end

    describe 'with dishes that have already been cleaned up' do
      let(:explicit_run_list) do
        [calling_recipe, first_wash_recipe, second_wash_recipe]
      end

      it_should_behave_like 'an empty sink'
    end

    describe 'with a mix of dishes that have been cleaned up and not' do
      let(:explicit_run_list) { [calling_recipe, first_wash_recipe] }
      let(:wash_recipes) { [second_wash_recipe] }
      it_should_behave_like 'a full sink'
    end

    # i.e. whose triggering recipes are still present in the run list
    describe 'with dishes that were never dirty' do
      let(:explicit_run_list) do
        [calling_recipe, first_dish_recipe, second_dish_recipe]
      end

      it_should_behave_like 'an empty sink'
    end

    describe 'with a mix of dishes that were dirtied and not' do
      let(:explicit_run_list) { [calling_recipe, first_dish_recipe] }
      let(:wash_recipes) { [second_wash_recipe] }
      it_should_behave_like 'a full sink'
    end

    describe 'with a mix of dishes that never dirty and already cleaned up' do
      let(:explicit_run_list) do
        [calling_recipe, first_dish_recipe, second_wash_recipe]
      end

      it_should_behave_like 'an empty sink'
    end
  end
end
