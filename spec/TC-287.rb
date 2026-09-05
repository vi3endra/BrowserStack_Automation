require_relative '../scripts/browserstack.rb'
require_relative '../helpers/session_helper.rb'
require_relative '../helpers/common_helper.rb'
require_relative '../helpers/xpath_helper.rb'

describe "Cart Functionality - TC-287 " do

  it "Item should be added to cart After Clicking Add to cart link" do
    # 1. Navigate to your domain first (Selenium requires being on the domain to set a cookie)
    SESSION_HELPER.visit_url $HOST_URL
    # 2. Inject a custom cookie that tells your application "This is an automated test"
    SESSION_HELPER.add_cookies_to_skip_cpatcha $HOST_DOMAIN
    initial_cart_item_count = 0

    # Add first item in cart and validate total cart item count
    com_click $bstack_product_add_to_cart_link.sub('?', "iPhone11"), "Add to cart Link for - iPhone11"
    com_wait_more
    is_checkout_cart_model_expanded = com_verify_element $bstack_cart_model_opened, do_iteration: "no"
    com_compare true, is_checkout_cart_model_expanded, "Checkout Cart Model Expanded: "
    initial_cart_item_count += 1
    current_cart_item_count = com_get_text $bstack_checkout_bag_quanity
    com_compare initial_cart_item_count, current_cart_item_count.to_i, "Current Cart item count: "
    com_click $bstack_checkout_cart_close_button, "Cart Close Button"

    # Add second item in cart and validate total cart item count
    com_click $bstack_product_add_to_cart_link.sub('?', "iPhone11"), "Add to cart Link for - iPhone11"
    com_wait_more
    is_checkout_cart_model_expanded = com_verify_element $bstack_cart_model_opened, do_iteration: "no"
    com_compare true, is_checkout_cart_model_expanded, "Checkout Cart Model Expanded: "
    initial_cart_item_count += 1
    current_cart_item_count = com_get_text $bstack_checkout_bag_quanity
    com_compare initial_cart_item_count, current_cart_item_count.to_i, "Current Cart item count: "

    # Decrease cart item quantity for first item and validate total cart item count change
    com_click $bstack_checkout_cart_decrease_quantity_button, "Cart - button"
    initial_cart_item_count -= 1
    current_cart_item_count = com_get_text $bstack_checkout_bag_quanity
    com_compare initial_cart_item_count, current_cart_item_count.to_i, "Current Cart item count: "
    com_click $bstack_checkout_cart_close_button, "Cart Close Button"
    is_checkout_cart_model_closed = com_verify_element $bstack_cart_model_opened, do_iteration: "no"
    com_compare true, !is_checkout_cart_model_closed, "Checkout Cart Model Closed: "

    # Add third item in cart and validate cart model expanded alongwith validate total cart item count change
    com_click $bstack_product_add_to_cart_link.sub('?', "iPhone12Pro"), "Add to cart Link for - iPhone12Pro"
    com_wait_more
    is_checkout_cart_model_expanded = com_verify_element $bstack_cart_model_opened, do_iteration: "no"
    com_compare true, is_checkout_cart_model_expanded, "Checkout Cart Model Expanded: "
    initial_cart_item_count += 1
    current_cart_item_count = com_get_text $bstack_checkout_bag_quanity
    com_compare initial_cart_item_count, current_cart_item_count.to_i, "Current Cart item count: "
  end

end
