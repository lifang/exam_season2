#encoding: utf-8
class Bus < ActiveRecord::Base
  has_many :invite_codes

  def self.generate_bus
    bus_code = "AAAA"
    last_bus = Bus.find(:first, :select => "max(num) num")
    letters = ('A'..'Z').to_a
    unless last_bus.nil?
      old_bus = last_bus.num.split("")
        if old_bus[3] < "Z"
          bus_code = old_bus[0, 3].join + letters.at(letters.index(old_bus[3]) + 1)
        else
          if old_bus[2] < "Z"
            bus_code = old_bus[0, 2].join + letters.at(letters.index(old_bus[2]) + 1) + "A"
          else
            if old_bus[1] < "Z"
              bus_code = old_bus[0] + letters.at(letters.index(old_bus[1]) + 1) + "AA"
            else
              bus_code = letters.at(letters.index(old_bus[0]) + 1) + "AAA"
            end
          end
        end
    end
    return bus_code
  end
  
end
