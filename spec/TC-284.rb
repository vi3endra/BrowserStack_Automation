require_relative '../scripts/browserstack.rb'
require_relative '../helpers/session_helper.rb'
require_relative '../helpers/common_helper.rb'
require_relative '../helpers/xpath_helper.rb'

describe "Login Authentication - TC-284 " do

  it "User is Logged In with Valid Credentials" do
    # 1. Navigate to your domain first (Selenium requires being on the domain to set a cookie)
    SESSION_HELPER.visit_url $HOST_URL
    # 2. Inject a custom cookie that tells your application "This is an automated test"
    SESSION_HELPER.add_cookies_to_skip_cpatcha $HOST_DOMAIN
    com_click $bstack_sign_in_link, "Sign In Link"
    com_wait_more
    is_sign_in_page_opened = com_verify_element $bstack_sign_in_username_dropdown, do_iteration: "no"
    com_compare true, is_sign_in_page_opened, "User navigated to Sign In page"
    com_click $bstack_sign_in_username_dropdown, "Username Dropdown"
    com_click $bstack_sign_in_password_dropdown_option.sub('?', "demouser"), "demouser Username"
    com_click $bstack_sign_in_password_dropdown, "Password Dropdown"
    com_click $bstack_sign_in_password_dropdown_option.sub('?', "testingisfun99"), "Password Encrypted"
    com_click $bstack_sign_in_log_in_button, "Log In button"
    is_sign_in_success = com_verify_element $bstack_logout_link
    com_compare true, is_sign_in_success, "User Log In Successfull"
  end

end
