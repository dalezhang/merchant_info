$(function () {
	console.log('fileupload')
    $('.fileupload').fileupload({
        dataType: 'json',
        formData: [
		    {
		        name: '_http_accept',
		        value: 'application/javascript'   
		    }, {
		        name: 'resource_attrname',
		        value: $('.fileupload').data('attrname')   
		    }, {
		        name: 'authenticity_token',
		        value: window._token 
		    }
		],
        done: function (e, data) {
        	$this = $(this);
        	$this.siblings('img.image-preview').attr('src', data.result.url)
            $.each(data.result.files, function (index, file) {
                $('<p/>').text(file.name).appendTo(document.body);
            });
        }
    });
});