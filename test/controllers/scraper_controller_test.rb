require 'test_helper'

class ScraperControllerTest < ActionDispatch::IntegrationTest
  test "should get select_dates" do
    get scraper_select_dates_url
    assert_response :success
  end

end
