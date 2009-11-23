# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # display a summary of a model instance, using the partial in <plural_class>/_summary.html.haml
  def summarize(instance)
    raise "Cannot summarize an empty object" unless instance
    klass = instance.class.name.underscore
    render :partial => "#{klass.pluralize}/summary", :locals => { klass.to_sym => instance }
  end

  # the minimal linked description of a model instance
  def brief(instance)
    raise "Cannot give a brief version of an empty object" unless instance
    link_to(instance.respond_to?(:name) ? instance.name : instance.to_s, instance)
  end
  
  # a readable list of brief versions of the provided model instances
  def list(*instances)
    return '' if instances.blank?
    instances.flatten.collect {|i| brief(i) }.join(", ")
  end
  
  def display_tree(tree)
    return '' if tree.blank?
    content_tag(:ul) do
      tree.inject('') do |buffer, node|
        if node.is_a?(Array)
          buffer << display_tree(node)
        else
          buffer << content_tag(:li, brief(node))
        end
        buffer
      end
    end
  end
end

