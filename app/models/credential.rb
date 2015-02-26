class Credential < ActiveRecord::Base
  
  validates :cred_type, presence:true
  validates :cred_type, uniqueness:true
    
end
