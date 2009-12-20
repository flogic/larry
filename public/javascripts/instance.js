jQuery(function($) {
  $('a.delete_parameter_link').livequery(
    function() {
      $(this).click(function() {
        $(this).parent().remove(); 
      });
    }
  );
  
  $('a#specify_end_time').livequery(
    function () {
      $(this).click(function() {
        $('#optional_end_time').hide();
        $('#end_time_label').show();
        $('#end_time_region').show();
        $('input#end_time_chooser').attr('value', $('input#start_time_chooser').attr('value'));
      });
    }
  );
});
