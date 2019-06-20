# Show/hide the Event fields on admin/posts form

$(document).on 'change', "select[name='effective_post[category]']", (event) ->
  obj = $(event.currentTarget)

  obj.closest('form').find("[class^='effective-post-category-']").hide()
  obj.closest('form').find(".effective-post-category-#{obj.val()}").show()

