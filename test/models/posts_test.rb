require 'test_helper'

class PostsTest < ActiveSupport::TestCase
  test 'is valid' do
    post = build_effective_post
    assert post.valid?
  end

  test 'published? and draft?' do
    post = build_effective_post()
    assert post.published?
    refute post.draft?

    post.update!(published_start_at: nil)
    refute post.published?
    assert post.draft?
    refute Effective::Post.published.include?(post)
    assert Effective::Post.draft.include?(post)

    post.update!(published_start_at: Time.zone.now)
    assert post.published?
    refute post.draft?
    assert Effective::Post.published.include?(post)
    refute Effective::Post.draft.include?(post)

    post.update!(published_end_at: Time.zone.now)
    refute post.published?
    assert post.draft?
    refute Effective::Post.published.include?(post)
    assert Effective::Post.draft.include?(post)

    post.update!(published_end_at: nil)
    assert post.published?
    refute post.draft?
    assert Effective::Post.published.include?(post)
    refute Effective::Post.draft.include?(post)

    post.update!(archived: true)
    refute post.published?
    refute post.draft?
    refute Effective::Post.published.include?(post)
    refute Effective::Post.draft.include?(post)
  end

end
