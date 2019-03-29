class RegistrationsController < ApplicationController
  
  before_action :set_registration, only: [:show, :edit, :update, :destroy]

  # GET /registrations
  def index
    @registrations = Registration.all
  end

  # GET /registrations/1
  def show
  end

  # GET /registrations/new
  def new
    @registration = Registration.new
    @order = Order.find_by id: params["order_id"]
    redirect_to new_errorpage_path  if @order.nil? || @order.order_items.count == 0
  end

  # POST /registrations
  def create
    @registration = Registration.new(registration_params)
    if @registration.save
      redirect_to @registration.paypal_url(registration_path(@registration))    
    else
      render :new
    end
  end

  protect_from_forgery except: [:hook]
  def hook
    params.permit! # Permit all Paypal input params
    status = params[:payment_status]
    if status == "Completed"
      binding.pry
      @registration = Registration.find params[:invoice]
      @registration.update_attributes notification_params: params, status: status, transaction_id: params[:txn_id], purchased_at: Time.now
    end
    render nothing: true
  end

  private
    
    def set_registration
      @registration = Registration.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def registration_params
      params.require(:registration).permit(:order_id, :address, :email, :user_name)
    end
end
