class GlobalSettings < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :value
  attr_accessible :name, :value

  def self.value_by_name(n)
    set = self.find_by_name(n)
    if set
      return set.value
    end
    return nil
  end
end
