require "test_helper"

class ManifestsTest < ActionDispatch::IntegrationTest
  test "the manifest names the app and points at its fingerprinted icon" do
    get manifest_path(format: :json)

    manifest = response.parsed_body
    assert_equal I18n.t("app.name"), manifest["name"]
    assert manifest["icons"].all? { it["src"].match?(%r{/assets/icon-\h+\.png}) }
  end

  test "pages link to the fingerprinted icon" do
    get new_session_path

    assert_select "link[rel=icon][href*='/assets/icon-']", count: 2
    assert_select "link[rel=manifest][href=?]", manifest_path(format: :json)
  end
end
