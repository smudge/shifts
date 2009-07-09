class PunchClocksController < ApplicationController
  def index
    @punch_clocks = PunchClock.all
  end
  
  def show
    @punch_clock = PunchClock.find(params[:id])
  end
  
  def new
    @user = User.find(current_user.id)
    @punch_clock = PunchClock.new(params[:id])
    @punch_clock.user = @user
    if @punch_clock.save
      flash[:notice] = "Successfully clocked in."
    else
      flash[:notice] = "Could not clock in."  # why?
    end
    redirect_to dashboard_url
  end
  
  def create
    raise penguins
    @punch_clock = PunchClock.new(params[:punch_clock])
    @user = User.find(params[:user_id])
    @punch_clock.user = @user
    if @punch_clock.save
      flash[:notice] = "Successfully created punchclock."
      redirect_to dashboard_url
    else
      render :action => 'new'
    end
  end

  def clock_out
    PunchClock.find(params[:id])
  end
  
  def cancel
    if (clock = current_user.punch_clock) && request.post?
      clock.destroy
    end
    redirect_to :controller => "/dashboard"
  end

  def clock_out
    @punch_clock = current_user.punch_clock
  end
  
  def destroy
    @punch_clock = current_user.punch_clock
    @time_in_hours = (Time.now - @punch_clock.created_at) / 3600.0  # sec -> hr
    @punch_clock.destroy
    flash[:notice] = "Successfully clocked out"
    @payform_item = PayformItem.new({:date => Date.today,
                                    :category_id => 2, # 2 for "shifts", there should be a better way
                                    :hours => @time_in_hours,
                                    :description => @punch_clock.description})
    @payform = Payform.build(current_department, current_user, Date.today)
    @payform_item.payform = @payform
    @payform_item.save
    @payform.save
    if current_user.is_admin_of?(current_department)
      redirect_to punch_clocks_path
    else  # clock deleted by user
      redirect_to dashboard_url
    end
  end
end
