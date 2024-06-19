/**
 * jQuery Mobile Menu 
 * Turn unordered list menu into dropdown select menu
 * version 1.0(31-OCT-2011)
 * 
 * Built on top of the jQuery library
 *   http://jquery.com
 * 
 * Documentation
 *   http://github.com/mambows/mobilemenu
 */
(function($) {
  $.fn.mobileMenu = function(options) {
      var defaults = {
          defaultText: 'Select',
          className: 'select-menu',
          subMenuClass: 'sub-menu',
          subMenuDash: '-'
      };

      var settings = $.extend(defaults, options);

      return this.each(function() {
          var $el = $(this);

          // Ensure the plugin is applied only once
          if ($el.data('mobileMenu')) {
              return; // Exit if already initialized
          }
          $el.data('mobileMenu', true);

          // Add class to submenu lists
          $el.find('ul').addClass(settings.subMenuClass);

          // Create the base select menu
          var $select = $('<select />', {
              'class': settings.className
          }).insertAfter($el);

          // Create default option
          $('<option />', {
              "value": '#',
              "text": settings.defaultText
          }).appendTo($select);

          // Create select options from menu items
          $el.find('a, .separator').each(function() {
              var $this = $(this),
                  optText = $this.text(),
                  optSub = $this.parents('.' + settings.subMenuClass),
                  len = optSub.length,
                  dash = '';

              // Add dashes to denote hierarchy
              if (len > 0) {
                  dash = Array(len + 1).join(settings.subMenuDash);
              }

              // Append options to select menu
              $('<option />', {
                  "value": this.href,
                  "html": dash + optText,
                  "selected": (this.href == window.location.href)
              }).appendTo($select);
          });

          // Change event handler for the select menu
          $select.change(function() {
              var locations = $(this).val();
              if (locations !== '#') {
                  window.location.href = locations;
              }
          });

          // Display the select menu
          $select.show();

      }); // End this.each
  };
})(jQuery);
