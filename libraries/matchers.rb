if defined?(ChefSpec)
  def use_dishes_dish(name)
    ChefSpec::Matchers::ResourceMatcher.new('dishes_dish', 'use', name)
  end

  def toss_dishes_dish(name)
    ChefSpec::Matchers::ResourceMatcher.new('dishes_dish', 'toss', name)
  end

  def wash_dishes_sink(name)
    ChefSpec::Matchers::ResourceMatcher.new('dishes_sink', 'wash', name)
  end
end
