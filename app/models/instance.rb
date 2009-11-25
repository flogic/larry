class Instance < ActiveRecord::Base
  include NormalizeNames
  
  belongs_to :app
  has_one   :deployment
  has_one   :host, :through => :deployment
  
  has_many :requirements
  has_many :services, :through => :requirements
  
  validates_presence_of :app
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :app_id
  
  serialize :parameters
  
  before_destroy :safe_to_delete?
  
  def customer
    app.customer
  end

  def required_services
    (services + services.collect(&:depends_on)).flatten
  end
  
  def configuration_name
    [customer.name, app.name, name].collect {|str| normalize_name(str) }.join('__')
  end
  
  def configuration_parameters
    parameters || {}
  end
  
  def unrelated_services
    Service.unrelated_services(services)
  end
  
  def requirement_for(service)
    return nil unless service
    requirements.find_by_service_id(service.id)
  end
  
  def needed_parameters
    services.collect(&:needed_parameters).flatten.compact.uniq
  end
  
  def matching_parameters
    (parameters || {}).slice(*needed_parameters)
  end
  
  def missing_parameters
    needed_parameters.select {|p| !(parameters || {}).has_key?(p) }
  end
  
  def unknown_parameters
    params = (parameters || {})
    params.slice(*(params.keys - needed_parameters))
  end
  
  def safe_to_delete?
    deployment.blank? and requirements.blank?
  end
  
  def can_deploy?
    return false if services.blank?
    missing_parameters.blank?
  end
end
