class RollCall < ApplicationRecord
  belongs_to :list
  belongs_to :student

  def self.get_by_date(employee, date)
    result = []
    lists = []
    
    if employee
      lists = employee.lists
    else
      lists = List.all.to_a
    end

    lists.each do |list|
      morning = list.get_roll_calls_by_round(date, "morning")
      afternoon = list.get_roll_calls_by_round(date, "afternoon")
      list.get_students.each do |student|
        RollCall.fill_with_blank(morning, student, list)
        RollCall.fill_with_blank(afternoon, student, list)
      end

      morning.sort!{|a,b| a.student.number.to_i <=> b.student.number.to_i}
      afternoon.sort!{|a,b| a.student.number.to_i <=> b.student.number.to_i}

      result << {
        date: date,
        class: list.name,
        morning: morning,
        afternoon: afternoon
      }
    end
    return result
  end

  def self.get_by_month(user, date, options={})
    if options[:format_api]
      is_month_report = true
      data = RollCall.create_data_dict(is_month_report, date)
    end
    return data
  end

  def as_json(option={})
    if option[:format_api]
      {
        code: student.code,
        first_name: student.first_name,
        last_name: student.last_name,
        prefix: student.prefix,
        number: student.number,
        status: self.status,
        missing: student.missing
      }
    else
      {
        student_id: student.id,
        list_id: self.list.id,
        created_at: self.created_at,
        updated_at: self.updated_at,
        check_date: self.check_date,
        round: self.round,
        cause: self.cause,
        status: self.status
      }
    end
  end

  private
  def self.fill_with_blank(roll_calls, student, list)
    found = false
    roll_calls.each do |rc_morning|
      found = true if rc_morning.student_id == student.id
    end
    if !found
      roll_calls << RollCall.new({
        student_id: student.id,
        list_id: list.id
      })
    end
  end

  def self.create_data_dict(is_month_report, date)
    arr = []
    data = []
    classroom = {}
    month = {}

    lists = List.all
    lists.each do |l|
      classroom = {}
      if is_month_report
        rollcalls = RollCall.where({ list_id: l.id, check_date: date.to_date.beginning_of_month..date.to_date.end_of_month })
      else
        rollcalls = RollCall.where( list_id: l.id )
      end
      rollcalls.each_with_index do |r,i|
        hash = {}
        date_m = {}
        date_a = {}
        morning = []
        afternoon = []
        status = {}

        dates = rollcalls.where(student_id: r.student_id)

        dates.each do |d|
          if d.round == "morning"
            date_m.store("#{d.check_date.to_date.day}", d.status)
          else
            date_a.store("#{d.check_date.to_date.day}", d.status)
          end
        end

        morning.push(date_m)
        afternoon.push(date_a)

        status.store("morning", morning)
        status.store("afternoon", afternoon)

        hash.store("code", r.student.student_number)
        hash.store("first_name", r.student.first_name)
        hash.store("last_name", r.student.last_name)
        hash.store("prefix", r.student.prefix)
        # hash.store("morning", rollcalls.where(round: "morning", student_id: r.student_id, check_date: r.check_date).first.status)
        # hash.store("afternoon", rollcalls.where(round: "afternoon", student_id: r.student_id, check_date: r.check_date).first.status)
        # hash.store("date", r.check_date)
        hash.store("status", status)

        if i > 0
          if arr.last["code"] != r.student.student_number
            arr.push(hash)
          end
        else
          arr.push(hash)
        end
      end
      classroom.store("class", l.name)
      classroom.store("student", arr)
      arr = []
      data.push(classroom)
      month.store("month", date.to_date.month)
      month.store("data", data)
    end
    return month
  end

end
