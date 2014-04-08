#
# Copyright © 2010-2014 Brian Welty <bkwelty@zoho.com>
#
# This file is part of Networth.
# 
# Networth is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# Networth is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class UserCategoriesController < ApplicationController
  before_filter :set_current_user, :only => [ :index, :create, :edit, :update, :destroy ]

  def redirect_target(account)
    if account
      account_user_categories_path(account)
    else
      user_categories_path
    end
  end

  def index
    @account = Account.from_params(params)
    @category_types = CategoryType.find(:all)

    current_user = User.find(session[:user_id])
    @user_categories = current_user.user_categories
    @category = Category.new
  end

  def create
    @account = Account.from_params(params)

    current_user = User.find(session[:user_id])
    @category = current_user.categories.new(params[:category])
    if @category.save
      redirect_to redirect_target(@account)
    else
      @user_categories = current_user.user_categories
      @category_types = CategoryType.find(:all)
      render :action => 'index'
    end
  end

  def edit
    @account = Account.from_params(params)
    @category_types = CategoryType.find(:all)

    @user = User.find(session[:user_id])
    @category = Category.find(params[:id])
    if @user.id != @category.user_id
      @user = nil
    end
  end

  def update
    @account = Account.from_params(params)

    @user = User.find(session[:user_id])
    @category = Category.find(params[:id])
    if @user.id != @category.user_id
      @user = nil
    end
    if @user and @category.update_attributes(params[:category])
      redirect_to redirect_target(@acccount)
    else
      @category_types = CategoryType.find(:all)
      render :action => "edit"
    end
  end

  def destroy
    @account = Account.from_params(params)

    @user = User.find(session[:user_id])
    @category = Category.find(params[:id])
    if @user.id != @category.user_id
      @user = nil
    end
    if @user and @category.use_count.zero?
      @category.destroy
    end
    redirect_to redirect_target(@acccount)
  end
end
