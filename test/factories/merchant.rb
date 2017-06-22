FactoryGirl.define do
  factory :merchant do
    user nil
    status '状态'
    full_name '商户全名称'
    name '商户简称'
    memo '商户备注'
    province '省份（字典'
    urbn  '城市（汉字标示'
    address '详细地址'
    appid '公众号'
    mch_type '商户类型(个体，企业)'
    industry '经营行业'
    t1_rate 1
    d0_rate 1
    partner_mch_id '123'
    #银行信息
    bank_info {{
        owner_name: 'owner_name', # 账户名称（账号名）
        bank_sub_code: 'bank_sub_code', # 支付联行号
        account_num: 'account_num', # 账号
        account_type: '个人', # 账户类型(个人，企业)
        owner_idcard: 'owner_idcard', # 持卡人身份证号码
        province: 'province', # 开户省
        urbn: 'urbn', # 开户市
        zone: 'zone', # 开户区
        bank_full_name: 'bank_full_name', # 银行全称
    }}
    # 法人信息
    legal_person {{
        identity_card_front_key: 'identity_card_front_key', # 身份证正面
        identity_card_back_key: 'identity_card_back_key',  # 身份证反面  
        tel: 'tel', # 联系人电话
        name: 'name', # 联系人名称
        email: 'email', # 联系人邮箱
        identity_card_num: 'identity_card_num', # 身份证号
    }}
    # 公司信息
    company {{
        shop_picture_key: 'shop_picture_key', # 店铺照
        license_key: 'license_key', # 营业执照
        contact_tel: 'contact_tel', # 联系人电话
        contact_name: 'contact_name', # 联系人姓名
        service_tel: 'service_tel', # 客服电话
        contact_email: 'contact_email', # 联系人邮箱
        license_code: 'license_code', # 营业执照编码
    }}
    request_and_response {{
      "zx_request": {
        "wechat": {
          "chnl_id": "10000022",
          "chnl_mercht_id": "zx_wechat_590831c49c301b1b94f83c9d",
          "pay_chnl_encd": "0002",
          "mercht_belg_chnl_id": "10000022",
          "mercht_full_nm": "深圳市普尔瀚达科技有限公司",
          "mercht_sht_nm": "普尔瀚达",
          "cust_serv_tel": "18688459010",
          "contcr_nm": "薛倩欣",
          "contcr_tel": "18688459010",
          "contcr_mobl_num": "18688459010",
          "contcr_eml": "asit@pooul.cn",
          "opr_cls": "19",
          "mercht_memo": "123",
          "prov": "广东",
          "urbn": "深圳",
          "dtl_addr": "科苑南路高新区（南区）留学生创业大厦3楼",
          "acct_nm": "雷有民",
          "opn_bnk": "中信银行",
          "is_nt_citic": "0",
          "acct_typ": 1,
          "pay_ibank_num": "302584060017",
          "acct_num": "124124125",
          "is_nt_two_line": 0,
          "lics_file_url": "http://op9mor5bf.bkt.clouddn.com/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
          "zx_contr_info_lists": [
            {
              "id": "591ec5599c301b2ee22e51db",
              "pay_typ_encd": "00020001",
              "pay_typ_fee_rate": "0.0030",
              "start_dt": "20161220"
            },
            {
              "id": "5922a0b09c301b26c8742ce0",
              "pay_typ_encd": "00020003",
              "pay_typ_fee_rate": "0.003",
              "start_dt": "20170510"
            }
          ]
        },
        "alipay": {
          "chnl_id": "10000022",
          "chnl_mercht_id": "zx_alipay_590831c49c301b1b94f83c9d",
          "pay_chnl_encd": "0001",
          "mercht_belg_chnl_id": "10000022",
          "mercht_full_nm": "深圳市普尔瀚达科技有限公司",
          "mercht_sht_nm": "普尔瀚达",
          "cust_serv_tel": "18688459010",
          "contcr_nm": "薛倩欣",
          "contcr_tel": "18688459010",
          "contcr_mobl_num": "18688459010",
          "contcr_eml": "asit@pooul.cn",
          "opr_cls": "2015050700000026",
          "mercht_memo": "123",
          "prov": "广东",
          "urbn": "深圳",
          "dtl_addr": "科苑南路高新区（南区）留学生创业大厦3楼",
          "acct_nm": "雷有民",
          "opn_bnk": "中信银行",
          "is_nt_citic": "0",
          "acct_typ": 1,
          "pay_ibank_num": "302584060017",
          "acct_num": "124124125",
          "is_nt_two_line": 0,
          "lics_file_url": "http://op9mor5bf.bkt.clouddn.com/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
          "zx_contr_info_lists": [
            {
              "id": "59229d2d9c301b26c8742cdf",
              "pay_typ_encd": "00010002",
              "pay_typ_fee_rate": "0.003",
              "start_dt": "20170510"
            }
          ]
        },
        "wechat_query": {
          "ROOT": {
            "Chnl_Id": "10000022",
            "Chnl_Mercht_Id": "zx_wechat_59228abcffea0e100d12cb98",
            "Pay_Chnl_Encd": "0002",
            "trancode": "0100SDC0",
            "Msg_Sign": "**"
          }
        },
        "alipay_query": {
          "ROOT": {
            "Chnl_Id": "10000022",
            "Chnl_Mercht_Id": "zx_alipay_59228abcffea0e100d12cb98",
            "Pay_Chnl_Encd": "0001",
            "trancode": "0100SDC0",
            "Msg_Sign": "**"
          }
        }
      },
      "zx_response": {
        "alipay_新增": {
          "ROOT": {
            "Chnl_Id": "10000022",
            "Chnl_Mercht_Id": "zx_alipay_590fe5d7ffea0e5f6dcb3ab8",
            "Pay_Chnl_Encd": "0001",
            "Rtrn_Doc": '',
            "Clr_Dtl": '',
            "Clr_Dt": '',
            "syn_file": '',
            "Dtl_Memo": '',
            "rtncode": "11000301",
            "rtninfo": "该商户已提交入驻或更新申请，在处理结束之前请勿重复提交。",
            "Msg_Sign": "**"
          }
        },
        "wechat_停用": {
          "ROOT": {
            "Chnl_Id": "10000022",
            "Chnl_Mercht_Id": "zx_wechat_590fe5d7ffea0e5f6dcb3ab8",
            "Pay_Chnl_Encd": "0002",
            "Rtrn_Doc": '',
            "Clr_Dtl": '',
            "Clr_Dt": '',
            "syn_file": '',
            "Dtl_Memo": '',
            "rtncode": "11000109",
            "rtninfo": "支付类型编码错误。",
          "Msg_Sign": "**"
        }
      },
      "alipay_停用": {
        "ROOT": {
          "Chnl_Id": "10000022",
          "Chnl_Mercht_Id": "zx_alipay_590fe5d7ffea0e5f6dcb3ab8",
          "Pay_Chnl_Encd": "0001",
          "Rtrn_Doc": '',
          "Clr_Dtl": '',
          "Clr_Dt": '',
          "syn_file": '',
          "Dtl_Memo": '',
          "rtncode": "11000203",
          "rtninfo": "不可废弃支付宝商户信息。",
          "Msg_Sign": "**"
        }
      },
      "wechat_变更": {
        "ROOT": {
          "Chnl_Id": "10000022",
          "Chnl_Mercht_Id": "zx_wechat_590831c49c301b1b94f83c9d",
          "Pay_Chnl_Encd": "0002",
          "Rtrn_Doc": '',
          "Clr_Dtl": '',
          "Clr_Dt": '',
          "syn_file": '',
          "Dtl_Memo": '',
          "rtncode": "11000109",
          "rtninfo": "支付类型编码错误。",
          "Msg_Sign": "**"
        }
      }
    },
    "pfb_request": {
      "wechat_offline": {
        "serviceType": '',
        "agentNum": "A147860093307610145",
        "outMchId": "wechat_offline_590831c49c301b1b94f83c9d",
        "customerType": "ENTERPRISE",
        "businessType": "204",
        "customerName": "深圳市普尔瀚达科技有限公司",
        "businessName": "普尔瀚达",
        "legalId": "620202198901190032",
        "legalName": "薛倩欣",
        "contact": "122222222",
        "contactPhone": "13800138000",
        "contactEmail": "asit@pooul.cn",
        "servicePhone": "18688459010",
        "address": "广东,深圳,科苑南路高新区（南区）留学生创业大厦3楼",
        "provinceName": "440000",
        "cityName": "440300",
        "districtName": "440305",
        "licenseNo": "21351235",
        "payChannel": "WECHAT_OFFLINE",
        "rate": "0.5",
        "t0Status": "N",
        "settleRate": "0",
        "fixedFee": "0",
        "isCapped": "N",
        "settleMode": "T1_AUTO",
        "upperFee": "0",
        "accountType": "PERSONAL",
        "accountName": "雷有民",
        "bankCard": "124124125",
        "bankName": "中信银行",
        "province": "1235",
        "city": "1235",
        "bankAddress": "中信银行",
        "alliedBankNo": "302584060017",
        "rightID": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "reservedID": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "IDWithHand": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "rightBankCard": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "licenseImage": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "doorHeadImage": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "accountLicence": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "appId": "315"
      },
      "wechat_app": {
        "serviceType": '',
        "agentNum": "A147860093307610145",
        "outMchId": "wechat_app_590831c49c301b1b94f83c9d",
        "customerType": "ENTERPRISE",
        "businessType": "204",
        "customerName": "深圳市普尔瀚达科技有限公司",
        "businessName": "普尔瀚达",
        "legalId": "620202198901190032",
        "legalName": "薛倩欣",
        "contact": "122222222",
        "contactPhone": "13800138000",
        "contactEmail": "asit@pooul.cn",
        "servicePhone": "18688459010",
        "address": "广东,深圳,科苑南路高新区（南区）留学生创业大厦3楼",
        "provinceName": "440000",
        "cityName": "440300",
        "districtName": "440305",
        "licenseNo": "21351235",
        "payChannel": "WECHAT_APP",
        "rate": "0.6",
        "t0Status": "N",
        "settleRate": "0",
        "fixedFee": "0",
        "isCapped": "N",
        "settleMode": "T1_AUTO",
        "upperFee": "0",
        "accountType": "PERSONAL",
        "accountName": "雷有民",
        "bankCard": "124124125",
        "bankName": "中信银行",
        "province": "1235",
        "city": "1235",
        "bankAddress": "中信银行",
        "alliedBankNo": "302584060017",
        "rightID": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "reservedID": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "IDWithHand": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "rightBankCard": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "licenseImage": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "doorHeadImage": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "accountLicence": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "appId": "315"
      },
      "alipay": {
        "serviceType": '',
        "agentNum": "A147860093307610145",
        "outMchId": "alipay_590831c49c301b1b94f83c9d",
        "customerType": "ENTERPRISE",
        "businessType": "204",
        "customerName": "深圳市普尔瀚达科技有限公司",
        "businessName": "普尔瀚达",
        "legalId": "620202198901190032",
        "legalName": "薛倩欣",
        "contact": "122222222",
        "contactPhone": "13800138000",
        "contactEmail": "asit@pooul.cn",
        "servicePhone": "18688459010",
        "address": "广东,深圳,科苑南路高新区（南区）留学生创业大厦3楼",
        "provinceName": "440000",
        "cityName": "440300",
        "districtName": "440305",
        "licenseNo": "21351235",
        "payChannel": "ALIPAY",
        "rate": "0.5",
        "t0Status": "N",
        "settleRate": "0",
        "fixedFee": "0",
        "isCapped": "N",
        "settleMode": "T1_AUTO",
        "upperFee": "0",
        "accountType": "PERSONAL",
        "accountName": "雷有民",
        "bankCard": "124124125",
        "bankName": "中信银行",
        "province": "1235",
        "city": "1235",
        "bankAddress": "中信银行",
        "alliedBankNo": "302584060017",
        "rightID": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "reservedID": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "IDWithHand": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "rightBankCard": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "licenseImage": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "doorHeadImage": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "accountLicence": "/590831c49c301b1b94f83c9d/FgvVn12TeuAGZD1GK-tWKfIRVEj6",
        "appId": "315"
      }
    },
    "pfb_response": {
      "wechat_offline_查询": {
        "return_code": "CS003001",
        "return_msg": "无效的下游商户号"
      },
      "wechat_offline_新增": {
        "return_code": "CS001004",
        "return_msg": "下游商户号已经存在"
      },
      "alipay_新增": {
        "return_code": "SIGN000001",
        "return_msg": "校验签名失败"
      },
      "alipay_查询": {
        "return_code": "000000",
        "return_msg": "操作成功",
        "customer": {
          "customerName": "深圳市普尔瀚达科技有限公司",
          "businessName": "普尔瀚达",
          "legalName": "薛倩欣",
          "contactPhone": "13800138000",
          "tradeStatus": "N",
          "customerType": "ENTERPRISE",
          "settleMode": "T1_AUTO",
          "contactEmail": "asit@pooul.cn",
          "cityName": "深圳",
          "appid": "315",
          "provinceName": "广东",
          "businessType": "204",
          "outMchId": "alipay_590fe5d7ffea0e5f6dcb3ab8",
          "contact": "深圳市普尔瀚达科技有限公司",
          "apiKey": "c68555c8703d4bdbb355a3b2af7b18a7",
          "auditStatus": "INIT",
          "districtName": "科苑南路高新区（南区）留学生创业大厦3楼",
          "licenseNo": "21351235",
          "customerNum": "C149628405233210282",
          "address": "广东,深圳,科苑南路高新区（南区）留学生创业大厦3楼",
          "legalId": "620202198901190032",
          "customerStatus": "CLOSED",
          "servicePhone": "18688459010",
          "t0Status": "N"
        },
        "bank": {
          "accountName": "雷有民",
          "province": "1235",
          "accountType": "COMPANY",
          "alliedBankNo": "302584060017",
          "bankName": "中信银行",
          "bankAddress": "中信银行",
          "city": "1235",
          "bankCard": "124124125"
        },
        "fee": {
          "WECHAT_OFFLINE_TRANS_FEE": {
            "rate": "0.50000000",
            "feeType": "TRANS_FEE"
          },
          "WECHAT_OFFLINE_SETTLE_FEE": {
            "fixedFee": "0.00000000",
            "isCapped": "N",
            "upperFee": "0.00000000",
            "feeType": "SETTLE_FEE",
            "settleRate": "0.00000000"
          }
        },
        "material": {
          "LICENSE": "FgvVn12TeuAGZD1GK-tWKfIRVEj6",
          "ID_WITH_HAND": "FgvVn12TeuAGZD1GK-tWKfIRVEj6",
          "ACCOUNT_LICENCE": "FgvVn12TeuAGZD1GK-tWKfIRVEj6",
          "DOOR_HEAD": "FgvVn12TeuAGZD1GK-tWKfIRVEj6",
          "RIGHT_ID": "FgvVn12TeuAGZD1GK-tWKfIRVEj6",
          "RIGHT_BANK_CARD": "FgvVn12TeuAGZD1GK-tWKfIRVEj6",
          "RESERVED_ID": "FgvVn12TeuAGZD1GK-tWKfIRVEj6"
        }
      },
      "wechat_app_查询": {
        "return_code": "CS003001",
        "return_msg": "无效的下游商户号"
      },
      "wechat_offline_变更": {
        "return_code": "CS002004",
        "return_msg": "无效的商户号"
      }
    }
    }}
  end

end
