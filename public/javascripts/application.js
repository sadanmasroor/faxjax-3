// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function deselect(selectElem) {
  $(selectElem).selectedIndex = -1;
}

function updateCharactersLeft(e, elem, num) {
  var left = num - elem.value.length;
  $(elem.id+"-charsleft").innerHTML = left >= 0 ? left : 0;
  if (elem.value.length >= num) {
    if(elem.value.length > num) elem.value = elem.value.substring(0, num);
    return isControlCharacter(e);
  }
}

function handlePINKeyUp(e, field, num) {
  if (field.value.length == 4 && num <= 2 && !isControlCharacter(e)) {
    $('key'+(num+1)).focus();
    $('key'+(num+1)).select();
  }
}

function isControlCharacter(e) {
  var code = (e.which) ? e.which : e.keyCode;
  switch(code) {
    case 8:   // backspace
    case 9:   // tab
    case 13:  // enter
    case 16:  // shift
    case 37:  // left arrow
    case 38:  // up arrow
    case 39:  // right arrow
    case 40:  // down arrow
    case 33:  // page up
    case 34:  // page down
    case 35:  // end
    case 36:  // home
    case 46:  // delete
      return true;
      break;
    default:
      return false;
      break;
  }
}

function go(url) {
  window.location.href=url;
}

// jQuery functs
//  make sure don't conflict with prototype
var $j = jQuery.noConflict();

$j(document).ready(function() {
  $j('#send-message-btn').toggle(function() {
    $j("#send-message").show()
  }, function() {
    $j("#send-message").hide()
  });
  
  function load_paypal() {
    // update paypal fields
    $j.ajax({
      url: "/sign_products/paypal_fields"
      , dataType: "html"
      , error: function (xhr, status, et) {
        alert("ajax error (load_paypal) " + status);
      }
      , success: function(data) {
        $j("#paypal_fields").html(data);
      }
    });
  }
  

  $j('#promo_code').change(function() {
    var promo_code = $j('#promo_code').val();
    var succeeded = false;
    
    $j.ajax({
      url: "/sign_products/promo_code" 
        , data: {promo_code: promo_code}
        , daraType: "json"
        , error: function(xhr, status, et) {
          alert("ajax error " + status);
        }
        , success: function(data) {
          if (data.discount == '$0.00') {
            $j("#discount").text('');
          } else {
            $j("#discount").text('(' + data.discount + ')');
          };
          $j("#subtotal").text(data.subtotal);
          $j("#total").text(data.total);
          //  update side cart
          $j("#cart-total").text(data.total);
          succeeded = true;
        }
        , complete: function(xhr, status) {
          if (succeeded) {
            load_paypal();
          }
        }
    });
  });

  // handle cart quantity change
  $j("input.quantity").change(function() {
    var target = $j(this);
    var key=$j(this).attr("id");
    var succeeded = false;
    $j.ajax({
      url: "/sign_products/change_qty" 
        , data: {key: key, value: $j(this).val()}
        , dataType: "json"
        , error: function(xhr, status, et) {
          alert("ajax error " + status);
        }
        , success: function(data, status, xhr) {
          succeeded = true;
          var items = data.items; 
          var price;
          for (i in items) {
            if (items[i].key == key) {
              price = items[i].line_price;
              $j('#line_price_'+key).text(price);
              
              target.val(""+items[i].qty+"");
              break;
            }
          }
          $j("#subtotal").text(data.subtotal);
          $j("#shipping").text(data.shipping);
          if (data.discount == '$0.00') {
            $j("#discount").text('');
          } else {
            $j("#discount").text('(' + data.discount + ')');
          };

          $j("#total").text(data.total);
          

          // update side cart
          $j("#sidecart-count").text(data.count);
          $j("#cart-count").text(data.count);
          $j("#cart-total").text(data.total);
        }
        , complete: function(xhr, status) {
          if (succeeded) {
            load_paypal();
          }
        }
        
    });
  });
  
});

