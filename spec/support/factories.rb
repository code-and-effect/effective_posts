require 'factory_girl'

FactoryGirl.define do
  factory :post, :class => Effective::Post do
    sequence(:title) { |n| "Title #{n}" }
    sequence(:slug) { |n| "title-#{n}" }

    meta_description 'meta description'
    draft false

    template 'example'
    layout 'application'
  end
end

