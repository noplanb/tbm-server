# This class should be subclassed by classes that store specific credentials in db
# Singleton instance of a specific cred_type intended to be allowed in the database.
module SpecificCredential
  extend ActiveSupport::Concern

  module ClassMethods
    def define_attributes(*attributes)
      self.credential_attributes = attributes.map(&:to_sym)

      credential_attributes.each do |attr|
        define_method attr do
          self.cred[attr]
        end

        define_method :"#{attr}=" do |value|
          self.cred[attr] = value
        end
      end
    end

    def instance
      find_or_create_by(cred_type: credential_type)
    end

    def credential_type
      name.gsub('Credential', '').underscore
    end
  end

  included do
    cattr_accessor :credential_attributes
    serialize :cred, HashWithIndifferentAccess
    after_initialize :set_cred_type, if: -> { cred_type.blank? }
    after_initialize :set_default_cred
  end

  def set_cred_type
    self.cred_type = self.class.credential_type
  end

  def set_default_cred
    self.cred = self.class.credential_attributes.each_with_object(cred) do |a, memo|
      memo[a] = nil
      memo
    end
  end

  def only_app_attributes
    self.cred.symbolize_keys
  end
end
