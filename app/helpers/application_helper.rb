# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # display a summary of a model instance, using the partial in <plural_class>/_summary.html.haml
  def summarize(instance)
    raise "Cannot summarize empty object" unless instance
    klass = instance.class.name.underscore
    render :partial => "#{klass.pluralize}/summary", :locals => { klass.to_sym => instance }
  end
end
