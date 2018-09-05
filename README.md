# Effective Posts

A blog implementation with WYSIWYG content editing, post scheduling, pagination and optional top level routes for each post category.

Built ontop of effective_regions for post content entry and Kaminari for pagination.

Rails 3.2.x and 4.x


## effective_posts 1.0

This is the 1.0 series of effective_posts.

This requires Twitter Bootstrap 4 and Rails 5.1+

Please check out [Effective Posts 0.x](https://github.com/code-and-effect/effective_posts/tree/bootstrap3) for more information using this gem with Bootstrap 3.

## Getting Started

Please first install the [effective_regions](https://github.com/code-and-effect/effective_regions) and [effective_datatables](https://github.com/code-and-effect/effective_datatables) gems.

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

There are no required javascript or stylesheet includes.


## Posts

To create your first post, visit `/admin/posts` and click `New Post`.

If you've defined more than one category in the `/app/config/initializers/effective_posts.rb` initializer, you will be asked to assign this post a category.  Otherwise the default category `posts` will be assigned.

You can schedule a post to appear at a later date by setting the published_at value to a future date.

If you're using the [effective_form_inputs](https://github.com/code-and-effect/effective_form_inputs) gem, the published_at input will be displayed with a nice bootstrap3 datetimepicker, otherwise it will use the default simple_form datetime input (which is pretty bad).

As well, if you're using the [effective_roles](https://github.com/code-and-effect/effective_roles) gem, you will be able to configure permissions so that only permitted users may view this post.

Once you click `Save and Edit Content` you will be brought into the effective_regions editor where you may enter the content for your post.  Click `Insert Snippet` -> `Read more divider` from the toolbar to place a divider into your post.  Only the content above the Read more divider, the excerpt content, will be displayed on any posts#index screens.  The full content will be displayed on the posts#show screen.


## Category Routes

If `config.use_category_routes` is enabled in the `/app/config/initializers/effective_posts.rb` initializer, each category you specify will automatically have a top level route.  So posts created in the `:blog` category will be available at `/blog` and any posts made in that category will be available at `/blog/1-my-post-title`.

If disabled, all posts will be available at `/posts`, with posts for a specific category available at `/posts?category=blog` and the show routes will be `/posts/1-my-post-title` regardless of category.


## Helpers

Use `link_to_post_category(:blog)` to display a link to the Blog page.  The helper considers `config.use_category_routes` and puts in the correct url.

Use `post_excerpt(post)` to display the excerpt for a post.  Or `post_excerpt(post, :length => 200)` to truncate it and add a Read more link where appropriate.


## Pagination

The [kaminari](https://github.com/amatsuda/kaminari) gem is used for pagination on all posts#index type screens.

The per_page for posts may be configured via the `/app/config/initializers/effective_posts.rb` initializer.

Included within this gem is the bootstrap3 theme for kaminari, but, as with any gem, your app-specific kaminari views will take priority over these included views.



## Authorization

All authorization checks are handled via the config.authorization_method found in the `app/config/initializers/effective_posts.rb` file.

It is intended for flow through to CanCan or Pundit, but neither of those gems are required.

This method is called by all controller actions with the appropriate action and resource

Action will be one of [:index, :show, :new, :create, :edit, :update, :destroy]

Resource will the appropriate Effective::Post object or class

The authorization method is defined in the initializer file:

```ruby
# As a Proc (with CanCan)
config.authorization_method = Proc.new { |controller, action, resource| authorize!(action, resource) }
```

```ruby
# As a Custom Method
config.authorization_method = :my_authorization_method
```

and then in your application_controller.rb:

```ruby
def my_authorization_method(action, resource)
  current_user.is?(:admin) || EffectivePunditPolicy.new(current_user, resource).send('#{action}?')
end
```

or disabled entirely:

```ruby
config.authorization_method = false
```

If the method or proc returns false (user is not authorized) an Effective::AccessDenied exception will be raised

You can rescue from this exception by adding the following to your application_controller.rb:

```ruby
rescue_from Effective::AccessDenied do |exception|
  respond_to do |format|
    format.html { render 'static_pages/access_denied', :status => 403 }
    format.any { render :text => 'Access Denied', :status => 403 }
  end
end
```

### Permissions

The permissions you actually want to define are as follows (using CanCan):

```ruby
can [:index, :show], Effective::Post

if user.admin?
  can :manage, Effective::Post
  can :admin, :effective_pages
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
