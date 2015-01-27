require "rubygems"
require "nokogiri"

# Modified from
# http://blog.madebydna.com/all/code/2010/06/04/ruby-helper-to-cleanly-truncate-html.html

module EffectiveTruncateHtmlHelper
  def chunk_html(text, max_length = 2, ellipsis = '...', read_more = nil)
    doc = Nokogiri::HTML::DocumentFragment.parse text

    if doc.children.length >= max_length
      doc.children.last.remove while doc.children.length > max_length
      doc.children.last.add_next_sibling Nokogiri::HTML::DocumentFragment.parse("<p>#{read_more.to_s}</p>")
    end

    doc.inner_html.html_safe
  end


  def truncate_html(text, max_length = 200, ellipsis = '...', read_more = nil)
    ellipsis_length = ellipsis.to_s.length
    doc = Nokogiri::HTML::DocumentFragment.parse text
    content_length = doc.inner_text.length
    actual_length = max_length - ellipsis_length

    if content_length > actual_length
      truncated_node = doc.truncate_html(actual_length)

      last_node = truncated_node
      while(last_node.respond_to?(:children) && last_node.children.present?)
        last_node = last_node.children.reverse.find { |node| node.try(:name) != 'a' } # Find the last non-A node
      end

      if read_more.present?
        read_more_node = Nokogiri::HTML::DocumentFragment.parse(read_more.to_s)
        last_node.add_next_sibling(read_more_node)
      end

      if ellipsis.present?
        ellipsis_node = Nokogiri::XML::Text.new(ellipsis.to_s, doc)
        last_node.add_next_sibling(ellipsis_node)
      end

      truncated_node.inner_html
    else
      text.to_s
    end.html_safe
  end

end

module NokogiriTruncator
  module NodeWithChildren
    def truncate_html(max_length)
      return self if inner_text.length <= max_length
      truncated_node = self.dup
      truncated_node.children.remove

      self.children.each do |node|
        remaining_length = max_length - truncated_node.inner_text.length
        break if remaining_length <= 10
        truncated_node.add_child node.truncate_html(remaining_length)
      end
      truncated_node
    end
  end

  module TextNode
    include ActionView::Helpers::TextHelper

    def truncate_html(max_length)
      truncated = truncate(content, :length => max_length, :separator => ' ', :omission => '')

      #Nokogiri::XML::Text.new(truncate(content.to_s, :length => (max_length-1)), parent)
      Nokogiri::XML::Text.new(truncated, parent)
    end
  end

end

Nokogiri::HTML::DocumentFragment.send(:include, NokogiriTruncator::NodeWithChildren)
Nokogiri::XML::Element.send(:include, NokogiriTruncator::NodeWithChildren)
Nokogiri::XML::Text.send(:include, NokogiriTruncator::TextNode)

