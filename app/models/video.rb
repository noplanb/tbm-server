class Video < ActiveRecord::Base
  belongs_to :user
    
  include Paperclip::Glue
  
  paperclip_options = {
    use_timestamp: false
  }
  if APP_CONFIG[:use_s3]
    paperclip_options = {
      use_timestamp: false,
      storage: :s3,
      s3_credentials: "#{Rails.root}/config/s3.yml",
      s3_permissions: :public_read_write,
    }
  end
    
  
  # has_attached_file :file, paperclip_options
  # validates_attachment_presence :file
  # do_not_validate_attachment_file_type :file
  validates_attachment_content_type :file, :content_type => /\A(audio|image|video)\/.*\Z/
  
  def self.create_or_update(params={})
    v = params[:filename] && find_by_filename(params[:filename])
    v && v.destroy
    create!(params)
  end
  
  private
  
end
