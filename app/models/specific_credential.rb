# This class should be subclassed by classes that store specific credentials in db
# Singleton instance of a specific cred_type intended to be allowed in the database.
module SpecificCredential
  extend ActiveSupport::Concern

  # Subclass should override these constants
  CRED_TYPE = "overrride_this_credtype"
  module ClassMethods
    def define_attributes(*attributes)
      self.credentail_attributes = attributes
      attr_accessor *attributes
    end

    def instance
      if found = find_by_cred_type(self::CRED_TYPE)
        found.set_attrs_with_cred
        return found
      else
        create
      end
    end

    def credentail_type
      name.gsub('Credential', '').underscore
    end
  end

  included do
    cattr_accessor :credentail_attributes
    before_save :set_cred_with_attrs
    after_initialize :set_cred_type
  end

  def set_cred_with_attrs
    cred_obj = {}
    self.class.credentail_attributes.each{|a| cred_obj[a] = send(a)}
    self.cred = cred_obj.to_json
  end

  def set_attrs_with_cred
    cred_obj = JSON.parse(self.cred).symbolize_keys
    self.class.credentail_attributes.each do |a|
      self.send(:"#{a}=", cred_obj[a])
    end
  end

  def set_cred_type
    self.cred_type = self.class.credentail_type
  end

  def only_app_attributes
    Hash[self.class.credentail_attributes.map{ |attr| [attr, public_send(attr)] }]
  end

end
