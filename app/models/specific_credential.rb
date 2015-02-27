# This class should be subclassed by classes that store specific credentials in db
# Singleton instance of a specific cred_type intended to be allowed in the database.
module SpecificCredential
  extend ActiveSupport::Concern

  module ClassMethods
    def define_attributes(*attributes)
      self.credential_attributes = attributes
      attr_accessor *attributes
    end

    def instance
      if found = find_by_cred_type(credential_type)
        found.set_attrs_with_cred
        found
      else
        create
      end
    end

    def credential_type
      name.gsub('Credential', '').underscore
    end
  end

  included do
    cattr_accessor :credential_attributes
    before_save :set_cred_with_attrs
    after_initialize :set_cred_type
  end

  def set_cred_with_attrs
    cred_obj = Hash[self.class.credential_attributes.map{ |a| [a, public_send(a)] }]
    self.cred = cred_obj.to_json
  end

  def set_attrs_with_cred
    cred_obj = JSON.parse(cred).symbolize_keys
    self.class.credential_attributes.each do |a|
      send(:"#{a}=", cred_obj[a])
    end
  end

  def set_cred_type
    self.cred_type = self.class.credential_type
  end

  def only_app_attributes
    Hash[self.class.credential_attributes.map { |attr| [attr, public_send(attr)] }]
  end
end
