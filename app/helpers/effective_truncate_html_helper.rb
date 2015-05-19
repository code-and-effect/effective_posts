module EffectiveTruncateHtmlHelper
  def chunk_html(text, max_length = 2, _ellipsis = '...', read_more = nil)
    doc = Nokogiri::HTML::DocumentFragment.parse text

    if doc.children.length >= max_length
      doc.children.last.remove while doc.children.length > max_length
      doc.children.last.add_next_sibling Nokogiri::HTML::DocumentFragment.parse("<p>#{ read_more }</p>")
    end

    doc.inner_html.html_safe
  end

  # Truncates HTML or text to a certain inner_text character limit.
  #
  # If given HTML, the underlying markup may be much longer than length, but the displayed text
  # will be no longer than (length + omission) characters.
  def truncate_html(text, length = 200, omission = '...')
    Nokogiri::HTML::DocumentFragment.parse(text).tap { |doc| _truncate_node(doc, length, omission) }.inner_html
  end

  def _truncate_node(node, length, omission)
    if node.inner_text.length <= length
      # Do nothing, we're already reached base case
    elsif node.name == 'a'
      node.remove # I don't want to truncate anything in a link
    elsif node.children.blank?
      # I need to truncate myself, and I'm certainly a text node
      if node.text?
        node.content = truncate(node.content, length: length, separator: ' ', omission: omission)
      else
        Rails.logger.info '[WARNING] effective_posts: unexpected node in children.blank? recursive condition'
        node.remove
      end
    else # Go through all the children, and delete anything after the length has been reached
      child_length = 0
      node.children.each do |child|
        child_length > length ? (child.remove) : (child_length += child.inner_text.length)
      end

      # We have now removed all nodes after length, but the last node is longer than our length
      # child_length is the inner_text length of all included nodes
      # And we only have to truncate the last child to get under length

      child = node.children.last
      child_max_length = length - (child_length - child.inner_text.length)

      _truncate_node(child, child_max_length, omission)
    end
  end
end
