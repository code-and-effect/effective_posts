# Effective Posts

A blog implementation with WYSIWYG content editing, post scheduling, pagination and optional top level routes for each post category.

## effective_posts 2.0

This is the 2.0 series of effective_posts.

This requires Twitter Bootstrap 4 and Rails 6+

Please check out [Effective Posts 0.x](https://github.com/code-and-effect/effective_posts/tree/bootstrap3) for more information using this gem with Bootstrap 3.

## Getting Started

Please first install the [effective_datatables](https://github.com/code-and-effect/effective_datatables) gem.

Please download and install [Twitter Bootstrap4](http://getbootstrap.com)

Add to your Gemfile:

```ruby
gem 'effective_posts'
```

Run the bundle command to install it:

```console
bundle install
```

Then run the generator:

```ruby
rails generate effective_posts:install
```

The generator will install an initializer which describes all configuration options and creates a database migration.

If you want to tweak the table name (to use something other than the default 'posts'), manually adjust both the configuration file and the migration now.

Then migrate the database:

```ruby
rake db:migrate
```


Add the following helper to your application layout in the `<head>..</head>` section. This works alongside effective_pages to include some publisher meta tags.

```ruby
= effective_posts_header_tags
```

There are no required javascript or stylesheet includes.


## Posts

To create your first post, visit `/admin/posts` and click `New Post`.

If you've defined more than one category in the `/app/config/initializers/effective_posts.rb` initializer, you will be asked to assign this post a category.  Otherwise the default category `posts` will be assigned.

You can schedule a post to appear at a later date by setting the published_at value to a future date.

As well, if you're using the [effective_roles](https://github.com/code-and-effect/effective_roles) gem, you will be able to configure permissions so that only permitted users may view this post.


## Category Routes

If `config.use_category_routes` is enabled in the `/app/config/initializers/effective_posts.rb` initializer, each category you specify will automatically have a top level route.  So posts created in the `:blog` category will be available at `/blog` and any posts made in that category will be available at `/blog/1-my-post-title`.

If disabled, all posts will be available at `/posts`, with posts for a specific category available at `/posts?category=blog` and the show routes will be `/posts/1-my-post-title` regardless of category.


## Helpers

Use `link_to_post_category(:blog)` to display a link to the Blog page.  The helper considers `config.use_category_routes` and puts in the correct url.

## Pagination

The [effective_bootstrap](https://github.com/code-and-effect/effective_bootstrap) gem is used for pagination on all posts#index type screens.

The per_page for posts may be configured via the `/app/config/initializers/effective_posts.rb` initializer.


## Authorization

All authorization checks are handled via the effective_resources gem found in the `config/initializers/effective_resources.rb` file.

### Permissions

The permissions you actually want to define are as follows (using CanCan):

```ruby
can [:index, :show], Effective::Post

if user.admin?
  can :manage, Effective::Post
  can :admin, :effective_posts
end
```

## Future Plans

There are some obvious additional features that have yet to be implemented:

- Tagging
- Some kind of helper for displaying a sidebar for the categories
- Post archives and date filtering

## License

MIT License.  Copyright [Code and Effect Inc.](http://www.codeandeffect.com/)

## Testing

Run tests by:

```ruby
guard
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Bonus points for test coverage
6. Create new Pull Request
