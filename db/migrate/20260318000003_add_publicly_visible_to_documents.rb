class AddPubliclyVisibleToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :publicly_visible, :boolean, default: true, null: false
  end
end
