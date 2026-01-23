/**
 * Phone input initialization with intl-tel-input library.
 * Provides country flag selection and phone validation.
 * Uses hiddenInput so the full international number is reliably submitted
 * (with separateDialCode the visible input holds only national part).
 */
document.addEventListener('DOMContentLoaded', function() {
    // Find phone input field - try different possible names
    var phoneInput = document.getElementById('phoneNumber') ||
                     document.getElementById('phone') ||
                     document.querySelector('input[name="phoneNumber"]') ||
                     document.querySelector('input[name="phone"]');

    if (!phoneInput || typeof intlTelInput === 'undefined') {
        return;
    }

    var fieldName = phoneInput.getAttribute('name') || phoneInput.id || 'phoneNumber';

    // Initialize intl-tel-input with hiddenInput: full number is submitted via
    // a hidden field. The visible input holds only national part with separateDialCode.
    var iti = intlTelInput(phoneInput, {
        initialCountry: 'ru',
        preferredCountries: ['ru', 'by', 'kz', 'uz', 'ua'],
        separateDialCode: true,
        nationalMode: false,
        formatOnDisplay: true,
        autoPlaceholder: 'aggressive',
        customPlaceholder: function(selectedCountryPlaceholder, selectedCountryData) {
            return selectedCountryPlaceholder;
        },
        utilsScript: 'https://cdn.jsdelivr.net/npm/intl-tel-input@25.3.1/build/js/utils.js',
        hiddenInput: function() {
            return { phone: fieldName };
        }
    });

    // Store iti instance for later access
    phoneInput.itiInstance = iti;

    // Remove name from visible input so only the hidden field (full number) is submitted.
    // Otherwise we'd submit both; visible input has national-only with separateDialCode.
    phoneInput.removeAttribute('name');

    // Real-time validation feedback
    phoneInput.addEventListener('blur', function() {
        validatePhone(iti, phoneInput);
    });

    phoneInput.addEventListener('input', function() {
        // Remove error state while typing
        var wrapper = phoneInput.closest('.pf-v5-c-form-control');
        if (wrapper) {
            wrapper.classList.remove('pf-m-error');
        }
        var errorMsg = phoneInput.parentElement.querySelector('.phone-error-message');
        if (errorMsg) {
            errorMsg.style.display = 'none';
        }
    });

    // Listen for country change
    phoneInput.addEventListener('countrychange', function() {
        validatePhone(iti, phoneInput);
    });

    function validatePhone(iti, input) {
        var wrapper = input.closest('.pf-v5-c-form-control');
        var errorMsg = input.parentElement.querySelector('.phone-error-message');

        // Skip validation if empty (let required validation handle it)
        if (!input.value.trim()) {
            if (wrapper) wrapper.classList.remove('pf-m-error');
            if (errorMsg) errorMsg.style.display = 'none';
            return;
        }

        if (iti.isValidNumber()) {
            if (wrapper) wrapper.classList.remove('pf-m-error');
            if (errorMsg) errorMsg.style.display = 'none';
        } else {
            if (wrapper) wrapper.classList.add('pf-m-error');
            // Error messages handled by Keycloak validation
        }
    }
});
