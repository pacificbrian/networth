class TaxYearsController < ApplicationController
  before_filter :get_current_user

  def index
    @tax_years = TaxYear.all
  end

  def show
    @tax_year = TaxYear.find(params[:id])
  end
end
