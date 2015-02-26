# This class should be subclassed by classes that store specific credentials in db
# Singleton instance of a specific cred_type intended to be allowed in the database. 
class SpecificCredential < Credential
  
  # Subclass should override these constants
  CRED_TYPE = "overrride_this_credtype"
  ATTRIBUTES = [:attr1, :attr2]
  # TODO: Alex: This must e copied in the subclass. Please show me a better way to do this.
  ATTRIBUTES.each do |a| 
    attr_accessor a
  end
  
  before_save :set_cred_with_attrs
  after_initialize :set_cred_type
  
  # def initialize(params={})
  #   params.merge!(cred_type: CRED_TYPE)
  #   super(params)
  # end
  
  def self.instance
    if found = find_by_cred_type(self::CRED_TYPE)
      found.set_attrs_with_cred
      return found
    else
      new
    end
  end
  
  def set_cred_with_attrs
    cred_obj = {}
    self.class::ATTRIBUTES.each{|a| cred_obj[a] = send(a)}
    self.cred = cred_obj.to_json
  end
  
  def set_attrs_with_cred
    cred_obj = JSON.parse(self.cred).symbolize_keys
    self.class::ATTRIBUTES.each do |a|
      setter = (a.to_s + "=").to_sym
      self.send(setter, cred_obj[a])
    end
  end
  
  def set_cred_type
    self.cred_type = self.class::CRED_TYPE
  end
  
end
