// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery(function() { 
  $('textarea').autogrow();
  $('a[rel*=facebox]').facebox();
  $('input.datetime').livequery(function() { $(this).datetime({
		userLang	: 'en',
		americanMode: true,
	}); });
}); 


