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

      morning.sort! {|a,b| a[0] <=> b[0]}
      afternoon.sort! {|a,b| a[0] <=> b[0]}

      morning = morning.collect {|rc| rc[1]}
      afternoon = afternoon.collect {|rc| rc[1]}

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

  def merge_classroom_number(_students)
    _students.each do |s|
      _number = s.classroom_number
      _number = 0 if _number.blank?
      if s.id == self.student_id
        return [_number, self]
      end
    end
  end

  def as_json(option={})
    if option[:format_api]
      st = self.student
      st = Student.with_deleted.where(id: student_id).first if self.student.blank?
      {
        code: st.code,
        first_name: st.first_name,
        last_name: st.last_name,
        prefix: st.prefix,
        number: st.number,
        status: self.status,
        missing: st.missing
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
      found = true if rc_morning[1].student_id == student.id
    end
    if !found
      _number = student.classroom_number
      _number = 0 if _number.blank?
      roll_calls << [ _number, RollCall.new({
        student_id: student.id,
        list_id: list.id
      })]
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

        hash.store("code", r.student.id)
        hash.store("first_name", r.student.first_name)
        hash.store("last_name", r.student.last_name)
        hash.store("prefix", r.student.prefix)
        # hash.store("morning", rollcalls.where(round: "morning", student_id: r.student_id, check_date: r.check_date).first.status)
        # hash.store("afternoon", rollcalls.where(round: "afternoon", student_id: r.student_id, check_date: r.check_date).first.status)
        # hash.store("date", r.check_date)
        hash.store("status", status)

        if i > 0
          if arr.last["code"] != r.student.id
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
