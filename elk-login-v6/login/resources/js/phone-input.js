/**
 * Phone input initialization with intl-tel-input library.
 * - Finds visible 'phone-visible' field for user input with country selector
 * - Stores phone number in hidden 'Phone' field as integer (e.g., 79154377861)
 * - Uses capture phase to ensure value is set before form submit
 */
document.addEventListener('DOMContentLoaded', function() {
    // Find visible phone field (user input) - can be 'phone-visible' or 'phone'
    var visibleInput = document.getElementById('phone-visible') ||
                       document.getElementById('phone') ||
                       document.getElementById('phoneNumber');

    if (!visibleInput || typeof intlTelInput === 'undefined') {
        return;
    }

    // Find hidden Phone field (where we store the integer value)
    var hiddenPhone = document.getElementById('Phone');

    if (!hiddenPhone) {
        console.warn('Hidden Phone field not found');
        return;
    }

    var form = visibleInput.closest('form');
    if (!form) {
        return;
    }

    console.log('Phone input initialized:', {
        visibleId: visibleInput.id,
        hiddenId: hiddenPhone.id,
        hiddenName: hiddenPhone.name,
        formId: form.id
    });

    // Initialize intl-tel-input on visible field
    var iti = intlTelInput(visibleInput, {
        initialCountry: 'ru',
        preferredCountries: ['ru', 'by', 'kz', 'uz', 'ua'],
        separateDialCode: true,
        nationalMode: false,
        formatOnDisplay: true,
        autoPlaceholder: 'aggressive',
        customPlaceholder: function(selectedCountryPlaceholder, selectedCountryData) {
            return selectedCountryPlaceholder;
        },
        utilsScript: 'https://cdn.jsdelivr.net/npm/intl-tel-input@25.3.1/build/js/utils.js'
    });

    visibleInput.itiInstance = iti;

    // Convert international number to integer format (remove + and spaces)
    function toIntegerFormat(number) {
        if (!number) return '';
        // Remove +, spaces, dashes, parentheses
        return number.replace(/[\s\+\-\(\)]/g, '');
    }

    // Function to update hidden Phone field
    function updateHiddenPhone() {
        try {
            var fullNumber = '';
            
            // Try to get full number using getNumber()
            try {
                fullNumber = iti.getNumber() || '';
            } catch (e) {
                console.warn('getNumber() failed, trying alternative method:', e);
            }
            
            // If getNumber() returns empty, construct from visible input and country code
            if (!fullNumber && visibleInput.value) {
                var countryData = iti.getSelectedCountryData();
                if (countryData && countryData.dialCode) {
                    // Get only digits from visible input
                    var nationalNumber = visibleInput.value.replace(/\D/g, '');
                    if (nationalNumber) {
                        fullNumber = '+' + countryData.dialCode + nationalNumber;
                    }
                }
            }
            
            var integerNumber = toIntegerFormat(fullNumber);
            hiddenPhone.value = integerNumber;
            
            console.log('Updating Phone field:', {
                visibleValue: visibleInput.value,
                fullNumber: fullNumber,
                integerNumber: integerNumber,
                hiddenValue: hiddenPhone.value,
                hiddenElement: hiddenPhone
            });
        } catch (e) {
            console.error('Error updating Phone field:', e);
        }
    }

    // Update hidden Phone field with integer format before form submit
    form.addEventListener('submit', function(e) {
        updateHiddenPhone();
        console.log('Form submit: Final Phone value:', {
            hiddenName: hiddenPhone.name,
            hiddenValue: hiddenPhone.value
        });
    }, true);

    visibleInput.addEventListener('blur', function() {
        updateHiddenPhone();
        validatePhone(iti, visibleInput);
    });

    visibleInput.addEventListener('input', function() {
        // Update hidden Phone field dynamically as user types
        updateHiddenPhone();
        
        var wrapper = visibleInput.closest('.pf-v5-c-form-control');
        if (wrapper) {
            wrapper.classList.remove('pf-m-error');
        }
        var errorMsg = visibleInput.parentElement.querySelector('.phone-error-message');
        if (errorMsg) {
            errorMsg.style.display = 'none';
        }
    });

    visibleInput.addEventListener('countrychange', function() {
        updateHiddenPhone();
        validatePhone(iti, visibleInput);
    });

    function validatePhone(iti, input) {
        var wrapper = input.closest('.pf-v5-c-form-control');
        var errorMsg = input.parentElement.querySelector('.phone-error-message');

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
        }
    }
});
