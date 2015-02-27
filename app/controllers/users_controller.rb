class UsersController < ApplicationController
  http_basic_authenticate_with name: Figaro.env.http_basic_username, password: Figaro.env.http_basic_password

  before_action :set_user, only: [:show, :edit, :update, :destroy, :new_connection, :establish_connection, :receive_test_video]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
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

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
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

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  # GET /users/new_connection/1
  def new_connection
    @users = User.all - [@user] - @user.connected_users
  end

  def establish_connection
    respond_to do |format|
      if connection = Connection.find_or_create(@user.id, params[:target_id])
        connection.update_attribute(:status, :established)
        format.html { redirect_to @user, notice: 'Connection was successfully created.' }
      else
        format.html { redirect_to @user, notice: 'Connection could not be created.' }
      end
    end
  end

  # Send test_video
  def receive_test_video
    sender = User.find params[:sender_id]
    video_id = create_test_video(sender, @user)
    add_remote_key(sender, @user, video_id)
    send_video_received_notification(sender, @user, video_id)
    redirect_to @user, notice: "Video sent from #{sender.first_name} to #{@user.first_name}."
  end

  private

  def create_test_video(sender, receiver)
    video_id = Time.now.to_i.to_s
    s3 = AWS::S3.new(access_key_id: S3Info.first.access_key, secret_access_key: S3Info.first.secret_key, region: S3Info.first.region)
    b = s3.buckets[S3Info.first.bucket]
    o = b.objects[video_filename(sender, receiver, video_id)]
    o.write(file: "#{Rails.root}/test_video.mp4")
    video_id
  end

  def video_filename(sender, receiver, video_id)
    c = Connection.live_between(sender.id, receiver.id).first
    "#{sender.mkey}-#{receiver.mkey}-#{c.ckey}-#{video_id}-filename"
  end

  def test_video
    Video.find_by_filename 'test_video'
  end

  def send_video_received_notification(sender, receiver, video_id)
    target_push_user = PushUser.find_by_mkey(receiver.mkey)
    gpn = GenericPushNotification.new(platform: target_push_user.device_platform,
                                      build: target_push_user.device_build,
                                      token: target_push_user.push_token,
                                      type: :alert,
                                      payload: { type: 'video_received',
                                                 from_mkey: sender.mkey,
                                                 video_id: video_id },
                                      alert: "New message from #{sender.first_name}",
                                      content_available: true)
    gpn.send
  end

  def add_remote_key(sender, receiver, video_id)
    conn = Connection.live_between(sender.id, receiver.id).first
    params = {}
    params[:key1] = "#{sender.mkey}-#{receiver.mkey}-#{conn.ckey}-VideoIdKVKey"
    params[:key2] = video_id
    params[:value] = { 'videoId' => video_id }.to_json
    Kvstore.create_or_update params
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :mobile_number, :device_platform, :auth, :mkey, :status)
  end
end
