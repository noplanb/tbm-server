class UsersController < AdminController
  before_action :set_user, only: [:show, :edit, :update, :destroy,
                                  :new_connection, :establish_connection,
                                  :receive_test_video, :receive_corrupt_video, :receive_permanent_error_video]
  def index
    if params[:user_id_or_mkey].present?
      user = User.where('id = ? OR mkey = ?', params[:user_id_or_mkey], params[:user_id_or_mkey]).first
      if user.present?
        redirect_to(user)
      else
        flash[:alert] = t('messages.user_not_found', query: params[:user_id_or_mkey])
      end
    end
    @users = User.search(params[:query]).page(params[:page])
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def new_connection
    @users = User.all - [@user] - @user.connected_users
  end

  def establish_connection
    respond_to do |format|
      connection = Connection.find_or_create(@user.id, params[:target_id])
      if connection
        connection.establish! if connection.may_establish?
        format.html { redirect_to :back, notice: 'Connection was successfully created.' }
      else
        format.html { redirect_to :back, notice: 'Connection could not be created.' }
      end
    end
  end

  def send_test_message
    @receiver = User.find(params[:user_id])
    @sender = User.find(params[:sender_id] || params[:message][:sender_id])

    if request.post?
      case params[:message][:type]
        when 'text'
          Users::SendTestMessage::Text.run!(
            sender: @sender, receiver: @receiver, body: params[:message][:body])
        when 'video'
          Users::SendTestMessage::Video.run!(
            sender: @sender, receiver: @receiver, file_name: params[:message][:file_name])
      end
      redirect_to :back, notice: 'Test message was successfully sent.'
    end
  end

  def receive_test_video
    file = Rails.root.join("#{params[:file] ? params[:file] : 'test_video_sani'}.mp4")
    if file.exist?
      receive_video(file)
    else
      redirect_to :back, alert: 'Video file not found.'
    end
  end

  def receive_corrupt_video
    receive_video(Rails.root.join('app/assets/images/orange-background.jpg'))
  end

  def receive_permanent_error_video
    receive_video(nil, without_s3_upload: true)
  end

  private

  def receive_video(file_name, options = {})
    sender = User.find(params[:sender_id])
    video_id = options[:without_s3_upload] ? test_video_id : create_test_video(sender, @user, file_name)
    Kvstore.add_id_key(sender, @user, video_id)
    @push_user = PushUser.find_by_mkey(@user.mkey) || not_found
    Notification::SendMessage.new(@push_user, request.host, current_user).process(params, sender.mkey, sender.first_name, video_id)
    redirect_to :back, notice: "Video sent from #{sender.first_name} to #{@user.first_name}."
  end

  def test_video_id
    (Time.now.to_f * 1000).to_i.to_s
  end

  def create_test_video(sender, receiver, file_name)
    video_id = test_video_id
    put_s3_object(sender, receiver, video_id, file_name)
    video_id
  end

  def put_s3_object(sender, receiver, video_id, file_name)
    cred = S3Credential.instance
    cred.s3_client.put_object(bucket: cred.bucket,
                              key: Kvstore.video_filename(sender, receiver, video_id),
                              body: File.read(file_name))
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :mobile_number, :emails, :device_platform, :auth, :mkey, :status)
  end
end
