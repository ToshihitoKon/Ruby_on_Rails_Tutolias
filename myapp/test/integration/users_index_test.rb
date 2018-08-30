require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end

  test "index not listed unactivated user" do
    @other_user.update_attribute(:activated, false)
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select 'a[href=?]', user_path(@other_user), count: 0
  end
  
  test "can access to activated users page" do
    get users_path(@other_user)
    assert_redirected_to login_path
  end

  test "cannot access to not activated users page" do
    @other_user.update_attribute(:activated, false)
    get users_path(@other_user)
    assert_redirected_to login_path
  end
end
