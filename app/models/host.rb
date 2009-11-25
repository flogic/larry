class Host < ActiveRecord::Base
  has_many :deployments
  has_many :instances, :through => :deployments

  validates_presence_of :name
  validates_uniqueness_of :name
  
  default_scope :order => :name
  
  before_destroy :safe_to_delete?
  
  def apps
    deployments.collect(&:app)
  end
  
  def customers
    deployments.collect(&:customer).flatten
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
    deployments.blank?
  end
end
