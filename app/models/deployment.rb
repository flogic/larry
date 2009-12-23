class Deployment < ActiveRecord::Base
  belongs_to :deployable
  belongs_to :host
  has_many :deployed_services
  
  named_scope :active, lambda {
    { :conditions => [ '(is_deactivated is null or is_deactivated=?) and start_time <= ? and (end_time is null or end_time > ?)', false, Time.now.utc, Time.now.utc ] }
  }
    
  validates_presence_of :deployable
  validates_presence_of :host
  validates_presence_of :reason
  validates_presence_of :start_time
  
  validate :start_time_must_not_be_in_past
  validate :end_time_must_not_be_in_past
  validate :non_nil_end_time_must_follow_start_time
  
  after_save :adjust_conflicting_deployments
  
  def self.deploy_from_deployable(deployable, params)
    params = HashWithIndifferentAccess.new(params)
    deployment = create!(:deployable => deployable, 
                         :start_time => params[:start_time], 
                         :reason     => params[:reason], 
                         :end_time   => params[:end_time],
                         :host_id    => params[:host_id])
    deployment_params = params.clone
    [ :start_time, :end_time, :reason].each {|key| deployment_params.delete(key) }
    deployment.deploy(deployment_params)
  end
  
  def deactivate
    update_attribute(:is_deactivated, true)
  end
  
  def deploy(params)
    return false unless deployed_services.empty?
    deployable.services.collect(&:name).each do |name| 
      deployed_services.create!(params.merge(:service_name => name, :parameters => deployable.service_parameters(name))) 
    end
    deployed_services
  end
  
  def undeploy
    return false if new_record? or !active?
    update_attribute(:end_time, Time.now)
    reload.end_time
  end
  
  def hosts
    deployed_services.collect(&:host).uniq
  end
  
  def instance
    return nil unless deployable
    deployable.instance
  end
  
  def app
    return nil unless deployable
    deployable.app
  end
  
  def customer
    return nil unless deployable
    deployable.customer
  end
  
  def services
    return nil unless deployable
    deployable.services
  end
  
  def active?
    return false if is_deactivated?
    return false unless start_time
    return false if start_time > Time.now
    return false if end_time and end_time <= Time.now
    true
  end
  
  def find_conflicting_deployments
    return [] unless host and deployable and instance
      instance.all_deployments.select do |d|
        d != self and
        !d.is_deactivated? and 
        (d.host_id == self.host_id) and
         ((d.start_time <= self.start_time and (d.end_time.nil?    or d.end_time    > self.start_time)) or
          (d.start_time  > self.start_time and (self.end_time.nil? or self.end_time > d.start_time)))
     end
  end
  
  protected
  
  def start_time_must_not_be_in_past
    errors.add(:start_time, "must not be in the past") if start_time and (Time.now - start_time > 60)
  end
  
  def end_time_must_not_be_in_past
    errors.add(:end_time, "must not be in the past") if end_time and (Time.now - end_time > 60)
  end
  
  def non_nil_end_time_must_follow_start_time
    errors.add(:end_time, "must come after start time") if end_time and start_time and (end_time < start_time)
  end
  
  def adjust_conflicting_deployments
    return true if is_deactivated?
    
    find_conflicting_deployments.each do |conflict|
      if conflict.start_time < self.start_time
        conflict.update_attribute(:end_time, self.start_time)
      else
        if end_time.nil?
          update_attribute(:end_time, conflict.start_time)
          reload
        else
          conflict.update_attribute(:start_time, self.end_time)
        end
      end
    end
    true  # return true to ensure that any later callbacks get called
  end
end
