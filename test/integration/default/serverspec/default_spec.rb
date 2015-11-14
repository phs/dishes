require 'spec_helper'

describe file('/tmp/first_wash_recipe_ran') do
  it { should_not exist }
end

describe file('/tmp/second_wash_recipe_ran') do
  it { should exist }
end
