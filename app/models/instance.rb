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
  
  def parameters
    self[:parameters] || {}
  end
  
  def customer
    return nil unless app
    app.customer
  end

  def required_services
    (services + services.collect(&:depends_on)).flatten
  end
  
  def configuration_name
    [customer.name, app.name, name].collect {|str| normalize_name(str) }.join('__')
  end
  
  def configuration_parameters
    (customer && customer.parameters || {}).merge(app && app.parameters || {}).merge(parameters)
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
    configuration_parameters.slice(*needed_parameters)
  end
  
  def missing_parameters
    needed_parameters.select {|p| !configuration_parameters.has_key?(p) }
  end
  
  def unknown_parameters
    configuration_parameters.slice(*(configuration_parameters.keys - needed_parameters))
  end
  
  def safe_to_delete?
    deployment.blank? and requirements.blank?
  end
  
  def can_deploy?
    return false if services.blank?
    missing_parameters.blank?
  end
  
  def puppet_manifest
    result = %Q(class #{configuration_name} {"#{configuration_name}":\n)
    configuration_parameters.each_pair do |key, value|
      result += %Q(  $#{key} = "#{value}"\n)
    end
    services.each do |service|
      result += %Q(  include #{service.configuration_name}\n)
    end
    result += "}\n"
    result += "include #{configuration_name}\n"
  end
  
  def parameter_whence(parameter)
    return nil unless configuration_parameters[parameter]
    return nil if parameters.has_key?(parameter)
    return app if app.parameters.has_key?(parameter)
    return customer if customer.parameters.has_key?(parameter)
  end
end
