class CreateSubMct < ActiveRecord::Migration[5.0]
  def change
	create_table "sub_mcts", force: :cascade do |t|
		t.integer  "org_id"
		t.string   "bank_mct_type"
		t.integer  "bank_mct_id"
		t.integer  "channel_id"
		t.string   "parent_mch_id"
		t.string   "mch_id"
		t.integer  "d0_enable",     default: 0
		t.integer  "sort_order",    default: 0
		t.string   "business_type"
		t.integer  "status",        default: 0
		t.datetime "created_at",                null: false
		t.datetime "updated_at",                null: false
		t.string   "trade_type"
		t.string   "name"
		t.index ["bank_mct_type", "bank_mct_id"], name: "index_sub_mcts_on_bank_mct_type_and_bank_mct_id"
		t.index ["channel_id"], name: "index_sub_mcts_on_channel_id"
		t.index ["org_id"], name: "index_sub_mcts_on_org_id"
	end
  end
end
