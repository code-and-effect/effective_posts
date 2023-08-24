require 'test_helper'

class PostsTest < ActiveSupport::TestCase
  test 'is valid' do
    post = build_effective_post
    assert post.valid?
  end
end
