class RollCall < ApplicationRecord
  belongs_to :list
  belongs_to :student

  def self.get_by_date(user, date, options={})
    if options[:format_api]
      result = []
      lists = user.lists
      lists = List.where(user_id: user.school.users.collect(&:id)).to_a if options[:all]
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

    sql = where({
      user_id: user.lists.collect{ |l| l.id },
      check_date: date
    })
    return sql

  end

  def self.get_by_permision(user, date, options={})
    if options[:format_api]
      result = []
      user.class_permisions.each do |p|
        list = List.find_by(id:p.list_id)
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

    sql = where({
      user_id: user.lists.collect{ |l| l.id },
      check_date: date
    })
    return sql

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

end
