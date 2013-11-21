class RawHTMLBlock < Block

  def self.description
    _('Raw HTML')
  end

  settings_items :html, :type => :text

  def content(args={})
    (title.blank? ? '' : block_title(title)).html_safe + expand_html(html).to_s.html_safe
  end

  def has_macro?
    true
  end

  protected

  def expand_html(content)
    if content && owner.kind_of?(Profile)
      content.gsub('{profile}', owner.identifier)
    else
      content
    end
  end

end
