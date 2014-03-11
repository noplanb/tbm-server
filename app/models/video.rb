class Video < ActiveRecord::Base
  belongs_to :user

  include Paperclip::Glue
  
  paperclip_options = {}
  if APP_CONFIG[:use_s3]
    paperclip_options = {
      storage: :s3,
      s3_credentials: "#{Rails.root}/config/s3.yml",
      s3_permissions: :public_read,
      bucket: APP_CONFIG[:s3_bucket]
    }
  end

  has_attached_file :file, paperclip_options
  validates_attachment_content_type :file, :content_type => /\A(audio|image|video)\/.*\Z/

end
