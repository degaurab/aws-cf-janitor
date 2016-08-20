class AwsDataController < ApplicationController
  before_action :set_aws_datum, only: [:show, :edit, :update, :destroy]

  # GET /aws_data
  # GET /aws_data.json
  def index
    @aws_data = AwsDatum.all
  end

  # GET /aws_data/1
  # GET /aws_data/1.json
  def show
  end

  # GET /aws_data/new
  def new
    @aws_datum = AwsDatum.new
  end

  # GET /aws_data/1/edit
  def edit
  end

  # POST /aws_data
  # POST /aws_data.json
  def create
    @aws_datum = AwsDatum.new(aws_datum_params)

    respond_to do |format|
      if @aws_datum.save
        format.html { redirect_to @aws_datum, notice: 'Aws datum was successfully created.' }
        format.json { render :show, status: :created, location: @aws_datum }
      else
        format.html { render :new }
        format.json { render json: @aws_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /aws_data/1
  # PATCH/PUT /aws_data/1.json
  def update
    respond_to do |format|
      if @aws_datum.update(aws_datum_params)
        format.html { redirect_to @aws_datum, notice: 'Aws datum was successfully updated.' }
        format.json { render :show, status: :ok, location: @aws_datum }
      else
        format.html { render :edit }
        format.json { render json: @aws_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /aws_data/1
  # DELETE /aws_data/1.json
  def destroy
    @aws_datum.destroy
    respond_to do |format|
      format.html { redirect_to aws_data_url, notice: 'Aws datum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_aws_datum
      @aws_datum = AwsDatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def aws_datum_params
      params.require(:aws_datum).permit(:aws_access_key, :aws_secret_key, :manifest_template)
    end
end
