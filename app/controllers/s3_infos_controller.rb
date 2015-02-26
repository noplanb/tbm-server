class S3InfosController < ApplicationController
  http_basic_authenticate_with :name => "admin", :password => "Statorama1", except: :info
  before_filter :authenticate, only: :info
  
  # =====================
  # = Mobile client api =
  # =====================
  def info
    render json: {status: "success"}.merge(S3Credential.instance.only_app_attributes)
  end
  
  # ================
  # = Admin screen =
  # ================
  before_action :set_s3_info, only: [:show, :edit, :update]

  # GET /s3_infos/1
  def show
  end


  # GET /s3_infos/1/edit
  def edit
  end

  # POST /s3_infos
  def create
    @s3_info = S3Info.new(s3_info_params)

    respond_to do |format|
      if @s3_info.save
        format.html { redirect_to @s3_info, notice: 'S3 info was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /s3_infos/1
  def update
    respond_to do |format|
      if @s3_info.update(s3_info_params)
        format.html { redirect_to @s3_info, notice: 'S3 info was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end



  private
    def set_s3_info
      @s3_info = S3Credential.instance
    end

    def s3_info_params
      params.require(:s3_info).permit(:region, :bucket, :access_key, :secret_key)
    end
end
