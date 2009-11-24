jQuery('div#add_customer_link a').livequery('click', function(event) {
  jQuery('#add_customer_link').toggle();
  jQuery('#add_customer_cancel_link').toggle();
  jQuery('div#add_customer').load(this.href).show();
  return false;
});

jQuery('div#add_customer_cancel_link a').livequery('click', function(event) {
  jQuery('#add_customer_link').toggle();
  jQuery('#add_customer_cancel_link').toggle();
  jQuery('div#add_customer').reset().hide();
  return false;
});
