#!/usr/bin/env ruby

require 'csv'

# CSV header for EPSON Photo+
@out_header = %w(
  氏名
  敬称
  郵便番号
  住所１
  住所２
  連名１
  敬称１
  連名２
  敬称２
  連名３
  敬称３
  連名４
  敬称４
  連名５
  敬称５
)

# CSV header definition of Shimauma Print
@in_header = {
  family_name:        3,
  first_name:         4,
  title:              11,
  post_code:          12,
  prefecture:         13,
  address1:           14,
  address2:           15,
  address3:           16,
  joint_family_name1: 17,
  joint_first_name1:  18,
  title1:             19,
  joint_family_name2: 20,
  joint_first_name2:  21,
  title2:             22,
  joint_family_name3: 23,
  joint_first_name3:  24,
  title3:             25,
  joint_family_name4: 26,
  joint_first_name4:  27,
  title4:             28,
  joint_family_name5: 29,
  joint_first_name5:  30,
  title5:             31
}

def attr(csv_row, attr_name)
  return csv_row[@in_header[attr_name.to_sym]] || ''
end

def validate_row(csv_row)
  # '住所１' and '住所２' must be up to 30 characters
  r = csv_row
  address1 = generate_address1(r)
  address2 = generate_address2(r)

  raise "#{address1} has more than 30 chars." if address1.length > 30
  raise "#{address2} has more than 30 chars." if address2.length > 30
end

def generate_address1(csv_row)
  r = csv_row
  return "#{attr(r, :prefecture)} #{attr(r, :address1)} #{attr(r, :address2)}"
end

def generate_address2(csv_row)
  return attr(csv_row, :address3)
end

def main
  unless ARGV[0]
    puts "Address file is not specified as argument"
    exit 1
  end

  input_file = ARGV[0]

  unless File.exists?(input_file)
    puts "Address file does not exist"
    exit 1
  end

  CSV.open('output.csv', 'w') do |out|
    out << @out_header

    CSV.foreach(input_file, headers: true) do |r|
      validate_row(r)
      out_row = []
      out_row << "#{attr(r, :family_name)} #{attr(r, :first_name)}"
      out_row << attr(r, :title)
      out_row << attr(r, :post_code)
      out_row << generate_address1(r)
      out_row << generate_address2(r)

      5.times do |i|
        family_name = "joint_family_name#{i+1}".to_sym
        first_name  = "joint_first_name#{i+1}".to_sym
        title = "title#{i+1}".to_sym

        out_row << "#{attr(r, family_name)} #{attr(r, first_name)}"
        out_row << attr(r, title)
      end

      out << out_row.map{|r| r&.strip!;  r == "" ? nil : r }
    end
  end
end

main if __FILE__ == $0
