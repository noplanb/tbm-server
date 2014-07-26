class Connection < ActiveRecord::Base
  
  include EnumHandler
    
  belongs_to :creator, :class_name => 'User'
  belongs_to :target, :class_name => 'User'
  
  # validates_presence_of :creator_id, :on => :create, :message => "can't be blank"
  # validates_presence_of :target_id, :on => :create, :message => "can't be blank"
  
  
  define_enum :status,[
                       :initiated, 
                       :established, 
                       :rejected, :rejected_ack, 
                       :voided, :voided_ack, 
                       :terminated_by_creator, :terminated_by_creator_ack,
                       :terminated_by_target, :terminated_by_target_ack,
                       ],
                       :sets => {
                         :live => [:initiated, :established]
                       },
                       :primary => true

  scope :for_user_id, lambda{|user_id| where ["creator_id = ? OR target_id = ?", user_id, user_id]}
  scope :between_creator_and_target, lambda{|creator_id, target_id| where ["creator_id = ? AND target_id = ?", creator_id, target_id]}
  
  def self.live_between(user1_id, user2_id)
    between_creator_and_target(user1_id, user2_id).live + between_creator_and_target(user2_id, user1_id).live
  end
  
  def self.find_or_create(creator_id, target_id)
    live_between(creator_id, target_id).first || create(creator_id: creator_id, target_id: target_id, status: :initiated)
  end
  
end
