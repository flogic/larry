class Deployment < ActiveRecord::Base
  belongs_to :deployable
  has_many :deployed_services
  
  validates_presence_of :deployable
  validates_presence_of :reason
  validates_presence_of :start_time
  
  validate :start_time_must_not_be_in_past
  validate :end_time_must_not_be_in_past
  validate :non_nil_end_time_must_follow_start_time
  
  def start_time_must_not_be_in_past
    errors.add(:start_time, "must not be in the past") if start_time and (Time.now - start_time > 60)
  end
  
  def end_time_must_not_be_in_past
    errors.add(:end_time, "must not be in the past") if end_time and (Time.now - end_time > 60)
  end
  
  def non_nil_end_time_must_follow_start_time
    errors.add(:end_time, "must come after start time") if end_time and start_time and (end_time < start_time)
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
    return false unless start_time
    return false if start_time > Time.now
    return false if end_time and end_time <= Time.now
    true
  end
end
