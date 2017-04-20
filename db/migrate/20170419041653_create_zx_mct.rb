class CreateZxMct < ActiveRecord::Migration[5.0]
  def change
    create_table "zx_mcts", force: :cascade do |t|
		t.integer  "org_id"
		t.string   "chnl_id"
		t.string   "chnl_mercht_id"
		t.string   "pay_chnl_encd"
		t.string   "mercht_belg_chnl_id"
		t.string   "opr_cls"
		t.string   "acct_nm"
		t.string   "opn_bnk"
		t.string   "is_nt_citic"
		t.string   "acct_typ"
		t.string   "pay_ibank_num"
		t.string   "acct_num"
		t.string   "is_nt_two_line"
		t.string   "comm_fee_acct_type"
		t.string   "comm_fee_acct_nm"
		t.string   "comm_fee_bank_nm"
		t.string   "ibank_num"
		t.string   "comm_fee_acct_num"
		t.string   "trancode"
		t.string   "submt_dt"
		t.string   "chk_dt"
		t.string   "actv_dt"
		t.string   "actv_stat"
		t.string   "rtncode"
		t.string   "rtninfo"
		t.integer  "status",              default: 0
		t.datetime "created_at",                      null: false
		t.datetime "updated_at",                      null: false
		t.index ["org_id"], name: "index_zx_mcts_on_org_id"
	end
  end
end
