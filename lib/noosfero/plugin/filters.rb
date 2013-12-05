module Noosfero::Plugin::Filters

  # This is a generic method that initialize any possible filter defined by a
  # plugin to the current controller being initialized.
  def plugin_filters
    Noosfero::Plugin.all.each do |plugin_name|
      plugin = plugin_name.constantize.new(self)
      filters = plugin.send(self.class.name.underscore + '_filters')
      filters = [filters] if !filters.kind_of?(Array)
      filters.each do |plugin_filter|
        self.class.send(plugin_filter[:type], plugin.class.name.underscore + '_' + plugin_filter[:method_name], (plugin_filter[:options] || {}))
        self.class.send(:define_method, plugin.class.name.underscore + '_' + plugin_filter[:method_name], plugin_filter[:block])
      end
    end
  end

end
