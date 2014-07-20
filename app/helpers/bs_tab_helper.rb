# http://ryanjafari.me/blog/2014/02/26/bootstrap-3-rails-tab-helper/
module TabHelper
  def bs_tabs(options = {}, &block)
    h = TabCollection.new(self, options)
    capture(h, &block)
    h.render
  end

  class TabCollection
    delegate :content_tag, to: :view

    def initialize(view, options)
      @view = view
      @tab_items = []
      @options = options
    end

    def render
      defaults = { class: 'nav nav-tabs' }
      tab_links = content_tag(:ul, li_content, defaults.update(@options))
      tab_content = content_tag(:div, pane_content, class: 'tab-content')
      tab_links + tab_content
    end

    def bs_tab_for(title, active = false, &block)
      tab_item = TabItem.new(title, @view.capture(&block), active)
      @tab_items << tab_item
    end

    protected

    attr_reader :view

    def li_content
      @tab_items.collect(&:li).join.html_safe
    end

    def pane_content
      @tab_items.collect(&:pane).join.html_safe
    end
  end

  class TabItem
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper

    def initialize(title, content, active = false)
      @id = SecureRandom.uuid
      @title = title
      @content = content
      @active = active
    end

    def li
      @li ||= content_tag(:li, link, class: ('active' if @active))
    end

    def pane
      @pane ||= begin
        pane_options = {
          class: "tab-pane #{'active' if @active}",
          id: @id
        }
        content_tag(:div, @content, pane_options)
      end
    end

    protected

    def link
      link_to @title, "##{@id}", data: { toggle: 'tab' }
    end
  end
end
