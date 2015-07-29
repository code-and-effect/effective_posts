module EffectiveTruncateHtmlHelper
  # Truncates HTML or text to a certain inner_text character limit.
  #
  # If given HTML, the underlying markup may be much longer than length, but the displayed text
  # will be no longer than (length + omission) characters.
  def truncate_html(text, length_or_content = 200, omission = '...')
    doc = Nokogiri::HTML::DocumentFragment.parse(text)

    if length_or_content.kind_of?(String)
      content = (Nokogiri::HTML::DocumentFragment.parse(length_or_content).children.first.inner_text rescue length_or_content)
      doc.tap { |doc| _truncate_node_to_content(doc, content, omission) }.inner_html
    elsif length_or_content.kind_of?(Integer)
      doc.tap { |doc| _truncate_node_to_length(doc, length_or_content, omission) }.inner_html
    else
      raise 'Unsupported datatype passed to second argument of truncate_html.  Expecting integer or string.'
    end
  end

  def _truncate_node_to_content(node, content, omission, seen = false)
    if seen == true
      node.remove
    elsif node.children.blank?
      index = node.content.index(content)

      if index.present?
        if node.parent.try(:content) == content # If my parent node just has my text in it, remove parent node too
          node.parent.remove
        elsif index == 0
          node.remove
        else
          node.content = truncate(node.content, length: index+omission.to_s.length, separator: ' ', omission: omission)
        end

        seen = true
      end
    else
      node.children.each { |child| seen = _truncate_node_to_content(child, content, omission, seen) }
    end

    seen
  end


  def _truncate_node_to_length(node, length, omission)
    if node.inner_text.length <= length
      # Do nothing, we're already reached base case
    elsif node.name == 'a'
      node.remove # I don't want to truncate anything in a link
    elsif node.children.blank?
      # I need to truncate myself, and I'm certainly a text node
      if node.text?
        node.content = truncate(node.content, length: length+omission.to_s.length, separator: ' ', omission: omission)
      else
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

      _truncate_node_to_length(child, child_max_length, omission)
    end
  end
end
