class UserSettings < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :name
  validates_presence_of :value
  attr_accessible :name, :value

  def self.value_by_name(user, n)
    set = user.user_settings.find_by_name(n)
    if set
      return set.value
    else
      set = self.user_settings.find_all_by_name(n)
      set.delete_if { |s| s.user_id != nil }
      if not set.empty?
        return set[0].value
      end
    end
    return nil
  end
end
