class Host < ActiveRecord::Base
  has_many :deployed_services

  validates_presence_of :name
  validates_uniqueness_of :name
  
  default_scope :order => :name
  
  before_destroy :safe_to_delete?

  def deployments
    deployed_services.collect(&:deployment).uniq
  end
  
  def deployables
    deployed_services.collect(&:deployable).uniq
  end
  
  def instances
    deployed_services.collect(&:instance).uniq
  end

  def apps
    deployed_services.collect(&:app).uniq
  end
  
  def customers
    deployed_services.collect(&:customer).uniq
  end
  
  def configuration
    instances.inject({ 'classes' => [], 'parameters' => {} }) do |h, instance|
      h['classes'] << instance.configuration_name
      h['parameters'][instance.configuration_name] = instance.configuration_parameters
      h
    end
  end
  
  def puppet_manifest
    instances.inject('') { |buffer, instance| buffer += instance.puppet_manifest }
  end
  
  def safe_to_delete?
    deployed_services.blank?
  end
end
