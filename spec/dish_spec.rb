require 'spec_helper'

describe 'dishes::dish' do
  let(:server_runner) { ChefSpec::ServerRunner.new step_into: 'dishes_dish' }
  let(:name) { 'the-name' }
  let(:calling_recipe) { 'test_dishes::dish_spec_recipe' }

  let(:action) { :use }
  let(:recipe) { 'dish_cookbook::dish_recipe' }
  let(:wash_recipe) { 'wash_cookbook::wash_recipe' }
  let(:sink) { 'the-sink' }

  let(:chef_run) do
    attrs = {}
    attrs['name'] = name if name
    attrs['action'] = action if action
    attrs['recipe'] = recipe if recipe
    attrs['wash_recipe'] = wash_recipe if wash_recipe
    attrs['sink'] = sink if sink

    server_runner.node.set['test_dishes']['dish_spec_recipe'] = attrs
    server_runner.converge(calling_recipe)
  end

  # Since we deal with state between runs, here is a nominally earlier run
  let(:prior_action) { action }
  let(:prior_recipe) { recipe }
  let(:prior_wash_recipe) { wash_recipe }
  let(:prior_sink) { sink }

  let(:prior_chef_run) do
    attrs = {}
    attrs['name'] = name if name
    attrs['action'] = prior_action if prior_action
    attrs['recipe'] = prior_recipe if prior_recipe
    attrs['wash_recipe'] = prior_wash_recipe if prior_wash_recipe
    attrs['sink'] = prior_sink if prior_sink

    server_runner.node.set['test_dishes']['dish_spec_recipe'] = attrs
    server_runner.converge(calling_recipe)
  end

  let(:resource) { chef_run.find_resource(:dishes_dish, name) }

  it 'runs' do
    chef_run
  end

  shared_examples_for 'a changed resource' do
    it 'is updated by the last action' do
      expect(resource).to be_updated_by_last_action
    end
  end

  shared_examples_for 'an unchanged resource' do
    it 'is not updated by the last action' do
      expect(resource).to_not be_updated_by_last_action
    end
  end

  # Throughout we cheat and assume there is only one dish in the recipe.

  describe 'without a recipe attribute' do
    let(:recipe) { nil }

    it 'assumes the name' do
      expect(resource.recipe).to eq(name)
    end
  end

  describe 'without a wash_recipe attribute' do
    let(:wash_recipe) { nil }

    it 'fails validation' do
      expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed)
    end
  end

  describe 'without a sink attribute' do
    let(:sink) { nil }

    it 'assumes "default"' do
      expect(resource.sink).to eq('default')
    end
  end

  describe 'with action :use' do
    let(:action) { :use }

    shared_examples_for 'a used dish' do
      it 'records itself in node attributes' do
        expect(chef_run.node['dishes']['dish'][name.to_s]).to eq(
          'recipe' => recipe,
          'wash_recipe' => wash_recipe,
          'sink' => sink
        )
      end

      it 'leaves no other state' do
        expect(chef_run.node['dishes']['dish'].size).to eq(1)
      end
    end

    describe 'on first run' do
      it_should_behave_like 'a used dish'
      it_should_behave_like 'a changed resource'
    end

    describe 'on second run without changes' do
      before do
        prior_chef_run
      end

      it_should_behave_like 'a used dish'
      it_should_behave_like 'an unchanged resource'
    end

    %w(recipe wash_recipe sink).each do |attribute|
      describe "on second run after changing #{attribute}" do
        let(:"prior_#{attribute}") { "different-#{attribute}" }

        before do
          prior_chef_run
        end

        it_should_behave_like 'a used dish'
        it_should_behave_like 'a changed resource'
      end
    end
  end

  describe 'with action :toss' do
    let(:action) { :toss }

    shared_examples_for 'a tossed dish' do
      it 'removes itself from node attributes' do
        expect(chef_run.node['dishes']['dish']).to_not have_key(name.to_s)
      end
    end

    describe 'on first run' do
      it_should_behave_like 'a tossed dish'
      it_should_behave_like 'an unchanged resource'
    end

    describe 'on second run without changes' do
      before do
        prior_chef_run
      end

      it_should_behave_like 'a tossed dish'
      it_should_behave_like 'an unchanged resource'
    end

    describe 'on second run after using' do
      let(:prior_action) { :use }

      before do
        prior_chef_run
      end

      it_should_behave_like 'a tossed dish'
      it_should_behave_like 'a changed resource'
    end
  end
end
