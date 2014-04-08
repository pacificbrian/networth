class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.integer :category_type_id
      t.boolean :omit_from_pie
    end

    create_table :category_types do |t|
      t.string :name
    end

    Category.create(:name => '--', :category_type_id => 0)
    Category.create(:name => 'Auto:Fuel', :category_type_id => 1)
    Category.create(:name => 'Auto:Parking', :category_type_id => 3)
    Category.create(:name => 'Auto:Parts', :category_type_id => 3)
    Category.create(:name => 'Auto:Registration', :category_type_id => 3)
    Category.create(:name => 'Auto:Service', :category_type_id => 1)
    Category.create(:name => 'Business', :category_type_id => 3)
    Category.create(:name => 'Cash', :category_type_id => 1)
    Category.create(:name => 'Charity', :category_type_id => 1)
    Category.create(:name => 'Unused', :category_type_id => 9)
    Category.create(:name => 'Clothing', :category_type_id => 1)
    Category.create(:name => 'Dining', :category_type_id => 1)
    Category.create(:name => 'Education', :category_type_id => 1)
    Category.create(:name => 'Electronics', :category_type_id => 1)
    Category.create(:name => 'Entertainment', :category_type_id => 1)
    Category.create(:name => 'Unused', :category_type_id => 9)
    Category.create(:name => 'Fees:Bank', :category_type_id => 1)
    Category.create(:name => 'Fees:Other', :category_type_id => 1)
    Category.create(:name => 'Unused', :category_type_id => 9)
    Category.create(:name => 'Health:Fitness', :category_type_id => 1)
    Category.create(:name => 'Gifts', :category_type_id => 3)
    Category.create(:name => 'Groceries', :category_type_id => 1)
    Category.create(:name => 'Unused', :category_type_id => 9)
    Category.create(:name => 'Home:Furnishings', :category_type_id => 3)
    Category.create(:name => 'Home:Furniture', :category_type_id => 1)
    Category.create(:name => 'Home:Repair', :category_type_id => 1)
    Category.create(:name => 'Household', :category_type_id => 1)
    Category.create(:name => 'Insurance:Auto', :category_type_id => 1)
    Category.create(:name => 'Insurance:Disability', :category_type_id => 3)
    Category.create(:name => 'Insurance:Life', :category_type_id => 1)
    Category.create(:name => 'Insurance:Medical', :category_type_id => 1)
    Category.create(:name => 'Insurance:Liability', :category_type_id => 3)
    Category.create(:name => 'Insurance:Property', :category_type_id => 1)
    Category.create(:name => 'Interest', :category_type_id => 1)
    Category.create(:name => 'Interest:Mortgage', :category_type_id => 3)
    Category.create(:name => 'Unused', :category_type_id => 9)
    Category.create(:name => 'Travel:Lodging', :category_type_id => 1)
    Category.create(:name => 'Medical:General', :category_type_id => 1)
    Category.create(:name => 'Medical:Dental', :category_type_id => 1)
    Category.create(:name => 'Unused', :category_type_id => 9)
    Category.create(:name => 'Medical:Pharmacy', :category_type_id => 1)
    Category.create(:name => 'Medical:Vision', :category_type_id => 3)
    Category.create(:name => 'Miscellaneous', :category_type_id => 1)
    Category.create(:name => 'Unused', :category_type_id => 9)
    Category.create(:name => 'Unused', :category_type_id => 9)
    Category.create(:name => 'Pet Care', :category_type_id => 1)
    Category.create(:name => 'Recreation', :category_type_id => 1)
    Category.create(:name => 'Rent', :category_type_id => 1)
    Category.create(:name => 'Shipping', :category_type_id => 3)
    Category.create(:name => 'Subscriptions', :category_type_id => 3)
    Category.create(:name => 'Taxes:Federal', :category_type_id => 1)
    Category.create(:name => 'Taxes:State', :category_type_id => 1)
    Category.create(:name => 'Taxes:Medicare', :category_type_id => 1)
    Category.create(:name => 'Taxes:Soc Sec', :category_type_id => 1)
    Category.create(:name => 'Taxes:SDI', :category_type_id => 3)
    Category.create(:name => 'Taxes:Property', :category_type_id => 1)
    Category.create(:name => 'Taxes:Foreign', :category_type_id => 3)
    Category.create(:name => 'Unused', :category_type_id => 9)
    Category.create(:name => 'Transportation', :category_type_id => 1)
    Category.create(:name => 'Travel', :category_type_id => 1)
    Category.create(:name => 'Utilities:Cable TV', :category_type_id => 1)
    Category.create(:name => 'Unused', :category_type_id => 9)
    Category.create(:name => 'Utilities:Energy', :category_type_id => 1)
    Category.create(:name => 'Unused', :category_type_id => 9)
    Category.create(:name => 'Utilities:Internet', :category_type_id => 1)
    Category.create(:name => 'Utilities:Telephone', :category_type_id => 1)
    Category.create(:name => 'Utilities:Trash', :category_type_id => 1)
    Category.create(:name => 'Utilities:Water', :category_type_id => 1)
    Category.create(:name => 'Wages:Salary', :category_type_id => 2)
    Category.create(:name => 'Wages:Bonus', :category_type_id => 2)
    Category.create(:name => 'Business Income', :category_type_id => 2)
    Category.create(:name => 'Dividend', :category_type_id => 2)
    Category.create(:name => 'Gift Income', :category_type_id => 2)
    Category.create(:name => 'Interest Income', :category_type_id => 2)
    Category.create(:name => 'Investment Income', :category_type_id => 2)
    Category.create(:name => 'Other Income', :category_type_id => 2)
    Category.create(:name => 'Rent Income', :category_type_id => 2)
    Category.create(:name => 'Resale Income', :category_type_id => 2)

    CategoryType.create(:name => 'Expense')
    CategoryType.create(:name => 'Income')
    CategoryType.create(:name => 'Additional Expense')
    # Maybe add a Other category, enabled when !additional
  end

  def self.down
    drop_table :categories
    drop_table :category_types
  end
end
