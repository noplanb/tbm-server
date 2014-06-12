class Video < ActiveRecord::Base
  belongs_to :user
  
  after_save :ensure_has_video_id
  
  include EnumHandler
  define_enum :status, [:uploaded, :downloaded, :viewed], :primary => true

  scope :sent_by, lambda { |user_id| where(user_id: user_id) }
  scope :sent_to, lambda { |user_id| where(receiver_id: user_id) }
  
  include Paperclip::Glue
  
  paperclip_options = {
    use_timestamp: false
  }
  if APP_CONFIG[:use_s3]
    paperclip_options = {
      use_timestamp: false,
      storage: :s3,
      s3_credentials: "#{Rails.root}/config/s3.yml",
      s3_permissions: :public_read,
      bucket: APP_CONFIG[:s3_bucket]
    }
  end

  has_attached_file :file, paperclip_options
  # validates_attachment_presence :file
  # do_not_validate_attachment_file_type :file
  validates_attachment_content_type :file, :content_type => /\A(audio|image|video)\/.*\Z/
  
  
  def self.find_last_with_user_id_and_receiver_id(user_id, receiver_id)
    where("receiver_id = ? and user_id = ?", receiver_id, user_id).order(id: :desc).limit(1).first
  end
  class << self
    alias_method :fromto, :find_last_with_user_id_and_receiver_id
  end
  
  def self.destroy_all_but_last_with_user_id_and_receiver_id(user_id, receiver_id)
    all = where("receiver_id = ? and user_id = ?", receiver_id, user_id).order(id: :desc)
    # all[1..-1] rather than (all - [all.first])??
    count = (all - [all.first]).each{|v| v.destroy!}.count
    logger.info "Video.destroy_all_but_last_with_user_id_and_receiver_id destroyed #{count} videos"
  end
  
  def self.create_by_decoding_video_id!(params)
    create! params.merge(Video.user_receiver_from_video_id(params[:video_id]))
  end
  
  def receiver
    User.find(receiver_id)
  end
  
  # Used to renotify of the availability of a video
  def notify
    gpn = GenericPushNotification.new({
      :platform  => self.receiver.device_platform, 
      :token => self.receiver.push_token, 
      :type => :alert, 
      :payload => {type: "video_received", 
                   from_id: self.user.id.to_s, 
                   video_id: self.video_id,
                   videosRequiringDownload: [self.video_id]},
      :alert => "New message from #{self.user.first_name.capitalize_words}", 
      :sound => "default", 
      :content_available  => true
    })
    gpn.send  
  end

  private
  
  def self.user_receiver_from_video_id(video_id)
    md = video_id.match(/(\d+)-(\d+)/)
    {user_id: md[1].to_i, receiver_id: md[2].to_i}
  end
  
  def ensure_has_video_id
    update_attribute(:video_id, generate_video_id) if video_id.blank?
  end
  
  def generate_video_id
    "#{user_id}-#{receiver_id}-#{User.find(user_id).first_name}-#{User.find(receiver_id).first_name}-server_generated-#{generate_random_string 20}"
  end
  
  def generate_random_string(length=10)
    r = ""
    length.times do 
      r += random_character
    end
    r
  end
  
  def random_character
    lower_start = 'a'.ord
    upper_start = 'A'.ord
    r = rand 52
    offset = r%26
    r/26 > 0 ? (lower_start + offset).chr : (upper_start + offset).chr
  end
  
end
