document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('[id^="input-error-container-"]').forEach(function(errorContainer) {
    if (errorContainer.querySelector('.pf-m-error')) {
      var prev = errorContainer.previousElementSibling;
      if (prev) {
        var input = prev.querySelector('input');
        if (input) {
          input.style.border = '1px solid #a30000';
        }
      }
    }
  });
}); 