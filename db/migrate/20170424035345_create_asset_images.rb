class CreateAssetImages < ActiveRecord::Migration[5.0]
  def change
    create_table :asset_images do |t|
		t.string   "filename"
		t.string   "avatar"
		t.string   "content_type"
		t.string   "resource_type", limit: 50
		t.integer  "resource_id"
		t.string   "thumbnail"
		t.datetime "created_at"
		t.string   "alt"
		t.string   "url"
		t.string   "image_type"
    end
  end
end
