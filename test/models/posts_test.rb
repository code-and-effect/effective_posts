require 'test_helper'

class PostsTest < ActiveSupport::TestCase
  test 'is valid' do
    post = build_effective_post
    assert post.valid?
  end

  test 'published? and draft?' do
    post = build_effective_post()
    post.save!
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

    post.update!(published_start_at: 2.minutes.ago, published_end_at: 1.minute.ago)
    refute post.published?
    assert post.draft?
    refute Effective::Post.published.include?(post)
    assert Effective::Post.draft.include?(post)

    post.update!(published_start_at: Time.zone.now, published_end_at: nil)
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

  test 'sitemap includes only public published unarchived posts' do
    post = build_effective_post()
    post.save!

    [nil, 0].each do |roles_mask|
      post.update!(roles_mask: roles_mask)
      assert Effective::Post.for_sitemap.exists?(post.id)
    end

    post.update!(roles_mask: 1)
    refute Effective::Post.for_sitemap.exists?(post.id)

    post.update!(roles_mask: 0, archived: true)
    refute Effective::Post.for_sitemap.exists?(post.id)

    post.update!(archived: false, published_start_at: 1.day.from_now)
    refute Effective::Post.for_sitemap.exists?(post.id)

    post.update!(published_start_at: 2.days.ago, published_end_at: 1.day.ago)
    refute Effective::Post.for_sitemap.exists?(post.id)
  end

end
