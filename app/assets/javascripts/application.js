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
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require chartkick
//= require_tree .


$(document).ready(function () {
    window.setInterval(function () {
        settingsmaintain();
        settingspost();
    }, 2000);
    $('#settings_high').keyup(function () {
        settingshigh();
    });
    $('#settings_high').change(function () {
        settingshigh();
    });
    $('#settings_low').keyup(function () {
        settingslow();
    });
    $('#settings_low').change(function () {
        settingslow();
    });
});

settingshigh = function () {
    settingsmaintain();
};

settingslow = function () {
    settingsmaintain();
};

settingsmaintain = function () {
    if (parseInt($('#settings_low').val()) > parseInt($('#settings_high').val())) {
        $('#settings_low').val(0);
    }
    if (parseInt($('#settings_low').val()) < 0) {
        $('#settings_low').val(0);
    }
    if (parseInt($('#settings_high').val()) < 0) {
        $('#settings_high').val(0);
    }
};

settingspost = function () {
    var high = $('#settings_high').val();
    var low = $('#settings_low').val();
    $.post('/wattsettings', { settings_high: high, settings_low: low });
};