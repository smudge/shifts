module NoticesHelper

  def department_check(dept)
    @notice.location_sources.all.each do |ls|
      return true if ls == dept
    end
    false
  end

  def loc_group_check(loc_group)
    @notice.loc_groups.each do |lg|
      return true if lg == loc_group
    end
    false
  end

  def location_check(location)
    @notice.locations.each do |loc|
      return true if loc == location
    end
    return @current_shift_location == location if @current_shift_location
    false
  end

  def type_check(sticky)
    if sticky
      @notice.is_sticky
    else
      !@notice.is_sticky
    end
  end

  def stime_check(not_time_choice)
    if not_time_choice
  end
end
end

