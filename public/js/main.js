$(document).ready(function(){
	
	$("#submittoken").click(function(){
		var token = $("#token").val();
		$.ajax({
			type: 'GET',
			url: '/rooms',
			data: 'token=' + token,
			success: function(response) {
				$("#rooms").html(response);
			},
			error: function( xhr, ajaxOptions, thrownError ) {
				console.log(thrownError);
			}
		});
	});
	
});