
if($("#list_tbody").size() > 0 ) {
      //修改
    $("#list_tbody").on("click", "a.modify", function () {
        // var _id = $(this).parent().parent().attr('id')
        $(this).parent().parent().find("select").removeAttr("disabled");
        $(this).parent().parent().find("input").removeAttr("disabled");



        //侦测开关状态
            var od;
        $('.temp_tr select').on('change',function () {
            od=this.value;
        })




            //保存
        $("#list_tbody").on("click", "a.save", function () {
            var _id = $(this).parent().parent().attr('id')
            $("#" + _id + " select").attr("disabled", true);
            $("#" + _id + " input").attr("disabled", true);






            console.log(this.value);
            var _id = $(this).parent().parent().attr('id')
            var data_arr = [];
            $($("#" + _id + " input[name='pay']:checked")).each(function () {
                data_arr.push($(this).val());
                return data_arr
            })
            var data_data = {
                //  "merchant_id": "59434ea6ffea0e25a6b0e6f7",
                //  "_id":_id,
                "priority": od,
                "pay_type": data_arr
            }
            data_data = JSON.stringify(data_data);
            $.ajax({
                url: 'http://gateway.pooulcloud.cn/cms/routes/' + _id,
                type: "put",
                data: data_data,
                dataType: "json",
                success: function (reData) {
                    if (reData.code == 0) {
                    }
                }
            });
        });


    });

    $.ajax({
        url: "http://gateway.pooulcloud.cn/cms/routes/?merchant",
        type: "get",
        data: {
            "merchant_id": $('#merchant_id').val(),
        },
        success: function (returnData) {
        	console.log('returnData', returnData);
            var checkedType = function (paytype) {
                paytype = JSON.stringify(paytype);
                var _id = $($('.temp_tr')[i]).attr("id");
                $('#' + _id + ' input[value=' + paytype + ']').prop('checked', 'true');
            }
            if (returnData.code == 0) {
                var htmlStr = '';
                for (var i = 0; i < returnData.data.length; i++) {
                    htmlStr += template("content-temp", returnData.data[i]);
                }
                $("#list_tbody").html(htmlStr);
                for (var i = 0; i < returnData.data.length; i++) {
                    var that = this;
                    for (var j = 0; j < returnData.data[i].pay_type.length; j++) {
                        checkedType(returnData.data[i].pay_type[j]);
                    }

                }

            }

        }
    });
}
if ($('#addform').size() > 0 ) {
    $("#add").on("click", "a.addbtn", function () {
        var channel_key = $("#channel-key input:text").val();
        var channel_name = $("#channel-name").val();
        var channel_mch_id = $("#channel-mch-id input:text").val();
        var priority = $("#priority").val();
        var channel_type = $("#channel-type").val();
        var data_arr = [];
        $($("#pay-type input[name='pay']:checked")).each(function () {
            data_arr.push($(this).val());
            return data_arr;
        });
        var tfb_name = $("#tfb_name input:text").val();
        var tfb_account= $("#tfb_account input:text").val();
        var tfb_type = $("#tfb_type input:text").val();
        var tfb_rate = $("#tfb_rate input:text").val();
        var CITIC_appid = $("#CITIC_appid input:text").val();
        var CITIC_key = $("#CITIC_key input:text").val();
        var CITIC_num = $("#CITIC_num input:text").val();
        var CITIC_ali = $("#CITIC_ali input:text").val();
        console.log(tfb_name);
        var data_data = {
            "merchant_id": $('#merchant_id').val(),
            "channel_key": channel_key,
            "channel_name": channel_name,
            "channel_mch_id": channel_mch_id,
            "priority": priority,
            "channel_type": channel_type,
            "pay_type": data_arr,
            "name":tfb_name,
            "account_id":tfb_account,
            "business_type":tfb_type,
            "ratio":tfb_rate,
            "sp_appid":CITIC_appid,
            "sp_key":CITIC_key,
            "sp_mch_id":CITIC_num,
            "sp_app_auth_token":CITIC_ali
        }
        data_data = JSON.stringify(data_data);
        if (channel_key == "" || channel_mch_id == "") {
            alert("添加失败，请添加完整的路由信息");
        }
        else {
            $.ajax({
                url: "http://gateway.pooulcloud.cn/cms/routes",
                type: "post",
                data: data_data,
                success: function (redata) {
                    if (redata.code == 0) {
                        alert("添加路由成功");
                        location.href = $("#index").val();
                    }
                }
            });
        }


    })
}
