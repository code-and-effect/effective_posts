module EffectiveTruncateHtmlHelper
  def chunk_html(text, max_length = 2, _ellipsis = '...', read_more = nil)
    doc = Nokogiri::HTML::DocumentFragment.parse text

    if doc.children.length >= max_length
      doc.children.last.remove while doc.children.length > max_length
      doc.children.last.add_next_sibling Nokogiri::HTML::DocumentFragment.parse("<p>#{ read_more }</p>")
    end

    doc.inner_html.html_safe
  end

  def truncate_html(text, max = 200, read_more = '', ellipsis = '...')
    doc = Nokogiri::HTML::DocumentFragment.parse(text)
    length = doc.inner_text.length

    while length > max
      element = doc
      element = element.last_element_child while element.last_element_child.present?
      # element is now the last nested element (i.e. an HTML node, NOT a text node) in the HTML, or doc itself if doc has no elements (text node)

      if (length - element.inner_text.length) > max  # If deleting this entire node means we're still over max, do it
        element.remove
      else # If we truncate this node, we'll be under max
        if element.name == 'a'
          element.remove  # I don't want to cut a link in half
        elsif element.children.length == 1 # There must be a text node here.  Can there be more than 1 text node?
          textNode = element.children.first
          textNode.content = truncate(textNode.content, length: (max - length), separator: ' ', omission: ellipsis)
          break # Break out of our while loop, as our ellipsis might invalidate our looping condition
        else # Unexpected, so just remove the whole thing
          Rails.logger.info "effective_posts, Unexpected number of last_element_child children"
          element.remove
        end
      end

      length = doc.inner_text.length
    end

    # Clean up any empty tags
    doc.last_element_child.remove while doc.last_element_child.try(:inner_html) == ''

    (doc.inner_html + read_more.to_s).html_safe
  end
end
