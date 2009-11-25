jQuery(function($) {
  $('a.delete_parameter_link').livequery(
    function() {
      $(this).click(function() {
        $(this).parent().remove(); 
      });
    }
  );
});
