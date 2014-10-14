class User < ActiveRecord::Base
  include EnumHandler
  
  has_many :connections_as_creator, :class_name => 'Connection', :foreign_key => :creator_id, :dependent => :destroy
  has_many :connections_as_target, :class_name => 'Connection', :foreign_key =>:target_id, :dependent => :destroy
  
  validates_uniqueness_of :mobile_number, :on => :create
  
  define_enum :device_platform, [:ios,:android], :primary => true
  
  # GARF: Change this to before_create when we finalize the algorithm for creating keys. Right now I incorporate id
  # in the key so I need to have after_create
  after_create :set_keys
  
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
  
  def connected_users_attributes_with_connection_status
    connected_users.map{|cu|
      con = Connection.live_between(id, cu.id).first;
      cu.attributes.symbolize_keys.merge(is_connection_creator: is_connection_creator(cu, con))
    }
  end
  
  def live_connection_count
    Connection.for_user_id(id).live.count
  end
  
  def set_keys
    update_attribute(:auth, gen_key("auth"))
    update_attribute(:mkey, gen_key("mkey"))
  end
  
  def gen_key(type)
    "#{first_name.gsub(" ", "")}_#{last_name}_#{id}_#{type}"
  end
  
  private
  
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
