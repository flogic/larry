class Host < ActiveRecord::Base
  has_many :all_deployed_services, :class_name => 'DeployedService', :foreign_key => 'host_id'
  has_many :all_deployments, :class_name => 'Deployment', :through => :all_deployed_services, :source => 'deployment'
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  default_scope :order => :name
  
  before_destroy :safe_to_delete?

  def deployments
    all_deployments.active
  end
  
  def deployed_services
    deployments.collect(&:deployed_services).flatten
  end

  def deployables
    deployments.collect(&:deployable).uniq
  end
  
  def instances
    deployments.collect(&:instance).uniq
  end

  def apps
    deployments.collect(&:app).uniq
  end
  
  def customers
    deployments.collect(&:customer).uniq
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
