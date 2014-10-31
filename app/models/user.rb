class User < ActiveRecord::Base
  include EnumHandler
  
  has_many :connections_as_creator, :class_name => 'Connection', :foreign_key => :creator_id, :dependent => :destroy
  has_many :connections_as_target, :class_name => 'Connection', :foreign_key =>:target_id, :dependent => :destroy
  
  validates_uniqueness_of :mobile_number, :on => :create
  
  define_enum :device_platform, [:ios,:android]
  define_enum :status, [:initialized, :verified], :primary => true
  
  # GARF: Change this to before_create when we finalize the algorithm for creating keys. Right now I incorporate id
  # in the key so I need to have after_create
  after_create :set_keys
  
  before_create :set_status_initialized
  
  def name
    [first_name,last_name].join(" ")
  end
  alias :fullname :name
  
  def info
    "#{name}[#{id}]"
  end
  
  def connected_user_ids
    live_connections = Connection.for_user_id(id).live
    live_connections.map{|c| c.creator_id == id ? c.target_id : c.creator_id}
  end
  
  def connected_users
    User.where ["id IN ?", connected_user_ids]
  end
  
  def live_connection_count
    Connection.for_user_id(id).live.count
  end
  
  def connection_count
    Connection.for_user_id(id).count
  end
  
  def set_keys
    update_attribute(:auth, gen_key("auth"))
    update_attribute(:mkey, gen_key("mkey"))
  end
  
  def gen_key(type)
    "#{first_name.gsub(" ", "")}_#{last_name}_#{id}_#{type}"
  end
  
  # ==================
  # = App Attributes =
  # ==================
  
  def only_app_attrs_for_user
    r = attributes.symbolize_keys.slice(:id, :auth, :mkey, :first_name, :last_name, :mobile_number, :device_platform)
    r[:id] = r[:id].to_s
    r
  end
  
  def only_app_attrs_for_friend
    r = attributes.symbolize_keys.slice(:id, :mkey, :first_name, :last_name, :mobile_number, :device_platform)
    r[:id] = r[:id].to_s
    r[:has_app] = device_platform.blank? ? "false" : "true"
    r
  end
  
  # =====================
  # = Verification code =
  # =====================
  def reset_verification_code
    set_verification_code if (verification_code.blank? || verification_code_will_expire_in?(2))   
  end
  
  def passes_verification(code)
    !verification_code_expired? && verification_code == code.gsub(/\s/, "")
  end
  
  def set_verification_code
    update_attributes verification_code: random_number(6), verification_date_time: (5.minutes.from_now)
  end
  
  def random_number(n)
    rand.to_s[2..n+1]
  end
  
  def verification_code_expired?
    verification_code_will_expire_in?(0)
  end
  
  def verification_code_will_expire_in?(n)
    return true if verification_code.blank? || :verification_date_time.blank?
    return true if verification_date_time < n.minutes.from_now
    return false
  end
  
  private
  
  def set_status_initialized
    status = :initialized
  end
  
  def is_connection_creator(connected_user, con)
    if connected_user.id == con.creator_id
      return true
    elsif connected_user.id == con.target_id
      return false
    else
      raise "connection_status: Connection does not belong to connected_user #{connected_user.id}"
    end 
  end
  
end
