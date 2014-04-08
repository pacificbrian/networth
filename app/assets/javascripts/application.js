// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_self

// this allows jquery to be called along with scriptaculous and YUI without any conflicts
// the only difference is all jquery functions should be called with $j instead of $
// e.g. $j('#div_id').stuff instead of $('#div_id').stuff
var $j = jQuery.noConflict();

$j(document).ready(function() {
    /* Activating Best In Place */
    jQuery(".best_in_place").best_in_place();
    // jQuery(".best_in_place").bind('ajax:success', function() { ... });
});
