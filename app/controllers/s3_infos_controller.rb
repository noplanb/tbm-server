class S3InfosController < ApplicationController
  http_basic_authenticate_with :name => "admin", :password => "Statorama1", except: :info
  before_filter :verify_user, only: :info
  
  # =====================
  # = Mobile client api =
  # =====================
  def info
    render json: {status: "success"}.merge(S3Info.first.only_app_attributes)
  end
  
  # ================
  # = Admin screen =
  # ================
  before_action :set_s3_info, only: [:show, :edit, :update, :destroy]

  # GET /s3_infos
  # GET /s3_infos.json
  def index
    @s3_infos = S3Info.all
  end

  # GET /s3_infos/1
  # GET /s3_infos/1.json
  def show
  end

  # GET /s3_infos/new
  def new
    redirect_to edit_s3_info_url(0) if S3Info.count > 0
    @s3_info = S3Info.new
  end

  # GET /s3_infos/1/edit
  def edit
  end

  # POST /s3_infos
  # POST /s3_infos.json
  def create
    @s3_info = S3Info.new(s3_info_params)

    respond_to do |format|
      if @s3_info.save
        format.html { redirect_to @s3_info, notice: 'S3 info was successfully created.' }
        format.json { render action: 'show', status: :created, location: @s3_info }
      else
        format.html { render action: 'new' }
        format.json { render json: @s3_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /s3_infos/1
  # PATCH/PUT /s3_infos/1.json
  def update
    respond_to do |format|
      if @s3_info.update(s3_info_params)
        format.html { redirect_to @s3_info, notice: 'S3 info was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @s3_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /s3_infos/1
  # DELETE /s3_infos/1.json
  def destroy
    @s3_info.destroy
    respond_to do |format|
      format.html { redirect_to s3_infos_url }
      format.json { head :no_content }
    end
  end

  private
    def set_s3_info
      # Allow only a single row to be created.
      @s3_info = S3Info.first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def s3_info_params
      params.require(:s3_info).permit(:region, :bucket, :access_key, :secret_key)
    end
end
