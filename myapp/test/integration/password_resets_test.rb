require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    # invalid password
    post password_resets_path, params: { password_reset: { email: "" } }
    assert flash.any?
    assert_template 'password_resets/new'
    # valid password
    post password_resets_path,
        params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert flash.any?
    assert_redirected_to root_url
    # test for password reset form
    user = assigns(:user)
    # invalid mail address
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # invalid user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # valid email address and invalid token
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # valid email address and valid token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    # invalid password and password_confirmation
    patch password_reset_path(user.reset_token),
        params: { email:  user.email,
                  user: { password:               "foobaz",
                          password_confirmation:  "barquux" } }
    assert_select 'div#error_explanation'
    # blank password and password_confirmation
    patch password_reset_path(user.reset_token),
        params: { email:  user.email,
                  user: { password:               "",
                          password_confirmation:  "" } }
    assert_select 'div#error_explanation'
    # valid password and password_confirmation
    patch password_reset_path(user.reset_token),
        params: { email:  user.email,
                  user: { password:               "foobaz",
                          password_confirmation:  "foobaz" } }
    assert is_logged_in?
    assert flash.any?
    assert_redirected_to user
    assert_equal nil, user.reload.reset_digest
  end

  test "expred token" do
    get new_password_reset_path
    post password_resets_path,
        params: { password_reset: { email: @user.email } }
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
        params: { email: @user.email,
                  user: { password:               "foobar",
                          password_confirmation:  "foobar" } }
    assert_response :redirect
    follow_redirect!
    assert_match 'expire', response.body
  end

end
