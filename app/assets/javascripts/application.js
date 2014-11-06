// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
// require jquery
//= require jquery-ui
//= require jquery.turbolinks
//= require jquery_ujs
//= require bootstrap
//= require tinymce-jquery
//= require turbolinks
//= require_tree .

document.createElement('aside');
document.createElement('article');

Turbolinks.enableTransitionCache();

$(document).on('ready page:change', function() {
  tinymce.init({
    selector: '.tinymce',
    plugins: ["link image code table fullscreen print preview media", "textcolor"],
    toolbar: "undo redo | styleselect | bold italic underline | forecolor backcolor emoticons | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent hr | link unlink image | print preview media fullscreen code ",
    height: 300
    })
})
