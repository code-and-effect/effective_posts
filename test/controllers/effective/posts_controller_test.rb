require 'test_helper'

class Effective::PostsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  tests Effective::PostsController

  setup do
    @routes = EffectivePosts::Engine.routes
  end

  test 'invalid page raises record not found before rendering' do
    error = assert_raises(ActiveRecord::RecordNotFound) do
      get :index, params: { page: 'invalid' }
    end

    assert_equal 'Page "invalid" is invalid', error.message
  end

  test 'page range is validated against the filtered posts' do
    EffectivePosts.per_page.times do |index|
      build_effective_post.tap do |post|
        post.title = "News #{index}"
        post.save!
      end
    end

    event = build_effective_post
    event.assign_attributes(category: EffectivePosts.event_categories.first, start_at: 1.day.from_now)
    event.save!

    error = assert_raises(ActiveRecord::RecordNotFound) do
      get :index, params: { category: event.category, page: 2 }
    end

    assert_equal 'Page 2 does not exist', error.message
  end
end
