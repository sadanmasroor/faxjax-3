//Gallery

function slideShow() {

	//Set the opacity of all images to 0
	$('#gallery a').css({opacity: 0.0});
	
	//Get the first image and display it (set it to full opacity)
	$('#gallery a:first').css({opacity: 1.0});
	
	//Set the caption background to semi-transparent
	$('#gallery .caption').css({opacity: 0.7});

	//Resize the width of the caption according to the image width
	$('#gallery .caption').css({width: $('#gallery a').find('img').css('width')});
	
	//Get the caption of the first image from REL attribute and display it
	$('#gallery .content').html($('#gallery a:first').find('img').attr('rel'))
	.animate({opacity: 0.7}, 400);
	
	//Call the gallery function to run the slideshow, 6000 = change to next image after 6 seconds
	setInterval('gallery()',6000);
	
}

function gallery() {
	
	//if no IMGs have the show class, grab the first image
	var current = ($('#gallery a.show')?  $('#gallery a.show') : $('#gallery a:first'));

	//Get next image, if it reached the end of the slideshow, rotate it back to the first image
	var next = ((current.next().length) ? ((current.next().hasClass('caption'))? $('#gallery a:first') :current.next()) : $('#gallery a:first'));	
	
	//Get next image caption
	var caption = next.find('img').attr('rel');	
	
	//Set the fade in effect for the next image, show class has higher z-index
	next.css({opacity: 0.0})
	.addClass('show')
	.animate({opacity: 1.0}, 1000);

	//Hide the current image
	current.animate({opacity: 0.0}, 1000)
	.removeClass('show');
	
	//Set the opacity to 0 and height to 1px
	$('#gallery .caption').animate({opacity: 0.0}, { queue:false, duration:0 }).animate({height: '1px'}, { queue:true, duration:300 });	
	
	//Animate the caption, opacity to 0.7 and heigth to 100px, a slide up effect
	$('#gallery .caption').animate({opacity: 0.7},100 ).animate({height: '70px'},500 );
	
	//Display the content
	$('#gallery .content').html(caption);
	
	
}

// Gallery 1 

function slideShow1() {

	//Set the opacity of all images to 0
	$('#gallery1 a').css({opacity: 0.0});
	
	//Get the first image and display it (set it to full opacity)
	$('#gallery1 a:first').css({opacity: 1.0});
	
	//Set the caption background to semi-transparent
	$('#gallery1 .caption').css({opacity: 0.7});

	//Resize the width of the caption according to the image width
	$('#gallery1 .caption').css({width: $('#gallery1 a').find('img').css('width')});
	
	//Get the caption of the first image from REL attribute and display it
	$('#gallery1 .content').html($('#gallery1 a:first').find('img').attr('rel'))
	.animate({opacity: 0.7}, 400);
	
	//Call the gallery function to run the slideshow, 6000 = change to next image after 6 seconds
	setInterval('gallery1()',6000);
	
}

function gallery1() {
	
	//if no IMGs have the show class, grab the first image
	var current = ($('#gallery1 a.show')?  $('#gallery1 a.show') : $('#gallery1 a:first'));

	//Get next image, if it reached the end of the slideshow, rotate it back to the first image
	var next = ((current.next().length) ? ((current.next().hasClass('caption'))? $('#gallery1 a:first') :current.next()) : $('#gallery1 a:first'));	
	
	//Get next image caption
	var caption = next.find('img').attr('rel');	
	
	//Set the fade in effect for the next image, show class has higher z-index
	next.css({opacity: 0.0})
	.addClass('show')
	.animate({opacity: 1.0}, 1000);

	//Hide the current image
	current.animate({opacity: 0.0}, 1000)
	.removeClass('show');
	
	//Set the opacity to 0 and height to 1px
	$('#gallery1 .caption').animate({opacity: 0.0}, { queue:false, duration:0 }).animate({height: '1px'}, { queue:true, duration:300 });	
	
	//Animate the caption, opacity to 0.7 and heigth to 100px, a slide up effect
	$('#gallery1 .caption').animate({opacity: 0.7},100 ).animate({height: '70px'},500 );
	
	//Display the content
	$('#gallery1 .content').html(caption);
	
	
}

//Gallery2 Banner js

function slideShow2() {

	//Set the opacity of all images to 0
	$('#gallery2 a').css({opacity: 0.0});
	
	//Get the first image and display it (set it to full opacity)
	$('#gallery2 a:first').css({opacity: 1.0});
	
	//Set the caption background to semi-transparent
	$('#gallery2 .caption').css({opacity: 0.7});

	//Resize the width of the caption according to the image width
	$('#gallery2 .caption').css({width: $('#gallery2 a').find('img').css('width')});
	
	//Get the caption of the first image from REL attribute and display it
	$('#gallery2 .content').html($('#gallery2 a:first').find('img').attr('rel'))
	.animate({opacity: 0.7}, 400);
	
	//Call the gallery function to run the slideshow, 6000 = change to next image after 6 seconds
	setInterval('gallery2()',6000);
	
}

function gallery2() {
	
	//if no IMGs have the show class, grab the first image
	var current = ($('#gallery2 a.show')?  $('#gallery2 a.show') : $('#gallery2 a:first'));

	//Get next image, if it reached the end of the slideshow, rotate it back to the first image
	var next = ((current.next().length) ? ((current.next().hasClass('caption'))? $('#gallery2 a:first') :current.next()) : $('#gallery2 a:first'));	
	
	//Get next image caption
	var caption = next.find('img').attr('rel');	
	
	//Set the fade in effect for the next image, show class has higher z-index
	next.css({opacity: 0.0})
	.addClass('show')
	.animate({opacity: 1.0}, 1000);

	//Hide the current image
	current.animate({opacity: 0.0}, 1000)
	.removeClass('show');
	
	//Set the opacity to 0 and height to 1px
	$('#gallery2 .caption').animate({opacity: 0.0}, { queue:false, duration:0 }).animate({height: '1px'}, { queue:true, duration:300 });	
	
	//Animate the caption, opacity to 0.7 and heigth to 100px, a slide up effect
	$('#gallery2 .caption').animate({opacity: 0.7},100 ).animate({height: '70px'},500 );
	
	//Display the content
	$('#gallery2 .content').html(caption);
	
	
}
