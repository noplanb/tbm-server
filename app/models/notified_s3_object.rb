class NotifiedS3Object < ActiveRecord::Base
  validates :file_name, uniqueness: true

  def self.persisted?(file_name)
    !where(file_name: file_name).empty?
  end
end
