class User < ActiveRecord::Base
  include EnumHandler
  
  has_many :connections_as_creator, :class_name => 'Connection', :foreign_key => :creator_id, :dependent => :destroy
  has_many :connections_as_target, :class_name => 'Connection', :foreign_key =>:target_id, :dependent => :destroy
  
  define_enum :device_platform, [:ios,:android], :primary => true
  
  # GARF: Change this to before_create when we finalize the algorithm for creating keys. Right now I incorporate id
  # in the key so I need to have after_create
  after_create :set_keys
  
  def name
    [first_name,last_name].join(" ")
  end
  
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
  
  def set_keys
    update_attribute(:auth, gen_key("auth"))
    update_attribute(:mkey, gen_key("mkey"))
  end
  
  def gen_key(type)
    "#{first_name}_#{last_name}_#{id}_#{type}"
  end
end
