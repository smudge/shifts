namespace :db do
  desc "Erase and fill database"

  task :populate => :environment do
    require 'populator'
    require 'faker'

    [Department, User, LocGroup, Location, TimeSlot, Shift].each do |model|
      model.delete_all
    end

    Department.create(:name => "STC", :monthly => false, :complex => false,
                      :day => 6)
    Department.create(:name => "Film studies", :monthly => true, :complex => false,
                      :day => 1)
    Department.create(:name => "Economics", :monthly => false, :complex => true,
                      :day => 6)
    Department.create(:name => "Political science", :monthly => true, :complex => true,
                      :day => 1, :day2 => 15)

    Department.all.each do |department|
      User.populate(50..200) do |user|
        user.first_name = Faker::Name.first_name
        user.last_name = Faker::Name.last_name
        user.login = user.first_name.downcase.first + user.last_name.downcase.first + (6 + rand(994)).to_s
        user.email = user.login + "@example.com"
        user.default_department_id = department.id
      end
    end

    User.all.each do |user|
      # This gem doesn't let you do habtm relationships, so this is a dumb way to accomplish that
      Department.find(user.default_department_id).users << user

      # This next part adds users to multiple departments by chance
      n = rand(10)
      while n == 0 do
        dept = Department.all[rand(Department.all.length)]
        dept.users << user
        n = rand(10)
      end
    end

    Department.all.each do |department|

      LocGroup.populate(3..8) do |loc_group|
        loc_group.name = Populator.words(1..3).titleize
        loc_group.department_id = department.id
        view_perm = Permission.create(:name => loc_group.name + " view")
        loc_group.view_perm_id = view_perm.id
        signup_perm = Permission.create(:name => loc_group.name + " signup")
        loc_group.signup_perm_id = signup_perm.id
        admin_perm = Permission.create(:name => loc_group.name + " admin")
        loc_group.admin_perm_id = admin_perm.id

        Location.populate(2..5) do |location|
          location.name = Populator.words(1..3).titleize
          location.short_name = location.name.split.first
          location.min_staff = 0..2
          location.max_staff = (location.min_staff) + rand(4)
          location.priority = 1..5
          location.active = true
          location.loc_group_id = loc_group.id

# For each department, for each day from now until some time in the future, 1 time slot is created from 9AM to 11PM
          (Date.today..2.years.from_now.to_date).each do |day|
            TimeSlot.populate(1) do |time_slot|
              time_slot.location_id = location.id
              time_slot.start = ("9AM " + day.to_s).to_datetime
              time_slot.end = ("11PM " + day.to_s).to_datetime
              time_slot.created_at = day.to_datetime
            end

            20.times do
              start_hour = 9 + rand(14)
              start_minute = 15 * rand(4)
              start_time = "#{start_hour}:#{start_minute}, #{day}".to_datetime
              end_time = start_time + (15 * (1 + rand(12))).minutes
              user = department.users[rand(department.users.length)]
              Shift.create(:start => start_time, :end => end_time, :user_id => user,
                           :location_id => location, :scheduled => true)
            end

          end

        end

      end


    end

  end
end

