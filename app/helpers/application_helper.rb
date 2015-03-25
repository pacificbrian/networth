# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def sum_amount(a)
    sum = 0
    a.each {|v| sum += v.amount }
    return sum
  end   

  def sum_gain(a)
    sum = 0
    a.each {|v| sum += v.gain }
    return sum
  end
end
