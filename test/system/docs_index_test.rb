require "application_system_test_case"

class DocsIndexTest < ApplicationSystemTestCase
  test "shows the docs landing page" do
    visit docs_path

    assert_text "Shared Doc Standard"
  end
end
