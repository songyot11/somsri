module ApplicationHelper
  def authenticate_authorizer!
    if current_user.present?
      authenticate_user!
    end
  end

  def current_authorizer
    if current_user.present?
      current_user
    end
  end

  def is_number?(string)
    true if Float(string) rescue false
  end

  def cleanNumber(stringOfNumber)
    return stringOfNumber.to_s.gsub(".00",'')
  end

  def roundNumber(numberOfMoney)
    if(numberOfMoney.round(2) == numberOfMoney.round(0))
      return numberOfMoney.round(0)
    else
      return numberOfMoney.round(2)    
    end
  end

  def thaiBaht(number)
    number = number.to_s
    if !number
      return ""
    end
    number.gsub!(",", "")
    number.gsub!(" ", "")
    number.gsub!("บาท", "")
    number.gsub!("฿", "")

    txt_num_arr = ["ศูนย์", "หนึ่ง", "สอง", "สาม", "สี่", "ห้า", "หก", "เจ็ด", "แปด", "เก้า", "สิบ"]
    txt_digit_arr = ["", "สิบ", "ร้อย", "พัน", "หมื่น", "แสน", "ล้าน"]
    baht_text = "";
    if is_number?(number)
      number = number.split(".");
      if number.length > 1 && number[1].length > 0
        number[1] = number[1][0..1]
      end
      number_len = number[0].length
      (0..(number_len-1)).each do |i|
        tmp = number[0][i..i].to_i
        if tmp != 0
          if ((i == (number_len - 1)) && (tmp == 1))
            baht_text += "เอ็ด"
          elsif ((i == (number_len - 2)) && (tmp == 2))
            baht_text += "ยี่"
          elsif ((i == (number_len - 2)) && (tmp == 1))
            baht_text += ""
          else
            baht_text += txt_num_arr[tmp]
          end
          baht_text += txt_digit_arr[number_len - i - 1]
        end
      end
      baht_text += "บาท"

      if number.length > 1 && number[1] != "0" && number[1] != "00"
        decimal_len = number[1].length
        (0..(decimal_len-1)).each do |i|
          tmp = number[1][i..i].to_i
          if tmp != 0
            if ((i == (decimal_len - 1)) && (tmp == 1))
              baht_text += "เอ็ด"
            elsif ((i == (decimal_len - 2)) && (tmp == 2))
              baht_text += "ยี่"
            elsif ((i == (decimal_len - 2)) && (tmp == 1))
              baht_text += ""
            else
              baht_text += txt_num_arr[tmp]
            end
            baht_text += txt_digit_arr[decimal_len - i - 1]
          end
        end
        baht_text += "สตางค์";
      else
        baht_text += "ถ้วน"
      end

      return baht_text
    else
      return ""
    end
  end

  def date_formatter(date)
    date.strftime('%d/%m/%Y')
  end

  def versions_with_user(versions)
    datas = []
    versions.each do |version|
      datas << {
        id: version.id,
        item_type: version.item_type,
        event: version.event,
        object: version.object,
        created_at: version.created_at,
        user: User.find_by(id: version.whodunnit)
      }
    end

    return datas
  end
end
