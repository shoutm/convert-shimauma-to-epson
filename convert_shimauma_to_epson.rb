#!/usr/bin/env ruby

require 'csv'

class AddressData
  # CSV header for EPSON Photo+
  @epson_address_header = %w(
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
  @shimauma_address_header = {
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
    title3:             25
  }

  class << self
    attr_accessor :epson_address_header, :shimauma_address_header
  end

  attr_accessor :csv_row

  # @input csv_row CSV::Row
  def initialize(csv_row)
    @csv_row = csv_row
  end

  def validate
    # '住所１' and '住所２' must be up to 30 characters
    raise "#{address1} has more than 30 chars." if address1.length > 30
    raise "#{address2} has more than 30 chars." if address2.length > 30
  end

  def name;      "#{_attr(:family_name)} #{_attr(:first_name)}";                   end
  def title;     _attr(:title);                                                    end
  def post_code; _attr(:post_code);                                                end
  def address1;  "#{_attr(:prefecture)} #{_attr(:address1)} #{_attr(:address2)}";  end
  def address2;  _attr(:address3);                                                 end
  def joint_name(index)
    family_name = "joint_family_name#{index}".to_sym
    first_name  = "joint_first_name#{index}".to_sym
    "#{_attr(family_name)} #{_attr(first_name)}"
  end
  def joint_name_title(index)
    _attr("title#{index}".to_sym)
  end

  private

  def _attr(attr_name)
    return csv_row[AddressData.shimauma_address_header[attr_name.to_sym]] || ''
  end
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
    out << AddressData.epson_address_header

    CSV.foreach(input_file, headers: true) do |r|
      data = AddressData.new(r)
      data.validate

      out_row = []
      out_row << data.name
      out_row << data.title
      out_row << data.post_code
      out_row << data.address1
      out_row << data.address2

      3.times do |i|
        out_row << data.joint_name(i+1)
        out_row << data.joint_name_title(i+1)
      end

      out << out_row.map{|r| r&.strip!;  r == "" ? nil : r }
    end
  end
end

main if __FILE__ == $0
