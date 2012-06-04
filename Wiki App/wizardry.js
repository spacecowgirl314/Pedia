$(document).ready(function(){
        $('table.toc').hide();
       
        var $tables = $('table').filter(function() { return $(this).parents('table').length == 0; });
        $tables.not(':first').not('table.toc').not('.infobox').not('.navbox').not('.metadata').not('.persondata').each(function()
        {
        	var openText = 'Show Table';
        	if ( $(this).find('caption').text().length > 0 )
        		openText = $(this).find('caption').text();
        	// Create psuedo element, then add the HTML, then insert into the dom, then add click listener
	        $('<a class="opentable" ontouchstart="" href="#" />')
	        	.html( openText )
	        	.insertBefore( $(this) )
	        	.click(function()
	        	{
	        		$(this).next('.tablepopup').toggle('fast'); // .find('table').show('fast');
		        	if ( $(this).html() == 'Hide Table' )
		        	{
		        		$(this).removeClass('opened').html(openText);
		        	}
		        	else
		        	{
		        		$(this).addClass('opened').html( 'Hide Table' );
		        	}
		        	return false;
	        	});
	    });
	    $tables.not(':first').not('.infobox').wrap('<div class="tablepopup" />');
	    
	    $('.tablepopup').hide();
});