actions :use, :toss
default_action :use

attribute :recipe, kind_of: String, name_attribute: true
attribute :wash_recipe, kind_of: String, required: true
attribute :sink, kind_of: String, default: 'default'
