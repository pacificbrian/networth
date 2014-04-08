class CreateCurrencyTypes < ActiveRecord::Migration
  def self.up
    create_table :currency_types do |t|
      t.string :name
      t.string :description
    end

    CurrencyType.create(:name => 'USD')
    CurrencyType.create(:name => 'AUD')
    CurrencyType.create(:name => 'BRL')
    CurrencyType.create(:name => 'CAD')
    CurrencyType.create(:name => 'CHF')
    CurrencyType.create(:name => 'EUR')
    CurrencyType.create(:name => 'GBP')
    CurrencyType.create(:name => 'JPY')
    CurrencyType.create(:name => 'NOK')
    CurrencyType.create(:name => 'NZD')
    CurrencyType.create(:name => 'SEK')
    CurrencyType.create(:name => 'XAU')
    CurrencyType.create(:name => 'XAG')
    CurrencyType.create(:name => 'ZAR')
  end

  def self.down
    drop_table :currency_types
  end
end
