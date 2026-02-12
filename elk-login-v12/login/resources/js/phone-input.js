/**
 * Phone input initialization with intl-tel-input library.
 * - Finds visible 'phone-visible' field for user input with country selector
 * - Stores phone number in hidden 'phone' field as integer (e.g., 79154377861)
 * - Uses capture phase to ensure value is set before form submit
 */
document.addEventListener('DOMContentLoaded', function() {
    // Visible field (user input) – used when attribute is "phone"
    var visibleInput = document.getElementById('phone-visible');
    var areaInput = document.getElementById('phone-area');
    var mainInput = document.getElementById('phone-main');

    if (!visibleInput || !areaInput || !mainInput || typeof intlTelInput === 'undefined') {
        return;
    }

    // Hidden phone field (stores integer value, submitted with form)
    var hiddenPhone = document.getElementById('phone');

    if (!hiddenPhone) {
        console.warn('Hidden phone field not found');
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

    // Initialize intl-tel-input on visible field (used only for region / dial code selector)
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

    // Format main part as ___-__-__ and keep only digits internally
    function formatMainPart(value) {
        var digits = (value || '').replace(/\D/g, '').slice(0, 7);
        var p1 = digits.slice(0, 3);
        var p2 = digits.slice(3, 5);
        var p3 = digits.slice(5, 7);

        var formatted = p1;
        if (digits.length > 3) {
            formatted += '-' + p2;
        }
        if (digits.length > 5) {
            formatted += '-' + p3;
        }

        return {
            digits: digits,
            formatted: formatted
        };
    }

    // Sync composite inputs (area + main) into hidden intl-tel visible input
    function syncCompositeToVisible() {
        // Area: strictly 3 digits
        var areaDigits = (areaInput.value || '').replace(/\D/g, '').slice(0, 3);
        areaInput.value = areaDigits;

        // Main part with mask ___-__-__
        var mainState = formatMainPart(mainInput.value || '');
        mainInput.value = mainState.formatted;

        // Combined local number (without brackets or dashes)
        var localNumber = areaDigits + mainState.digits;

        // Store pure digits in the underlying visible input used by intl-tel-input
        visibleInput.value = localNumber;

        return {
            areaDigits: areaDigits,
            mainDigits: mainState.digits,
            localNumber: localNumber
        };
    }

    // Convert international number to integer format (remove + and spaces)
    function toIntegerFormat(number) {
        if (!number) return '';
        // Remove +, spaces, dashes, parentheses
        return number.replace(/[\s\+\-\(\)]/g, '');
    }

    // Function to update hidden phone field
    function updateHiddenPhone() {
        try {
            var composite = syncCompositeToVisible();
            var fullNumber = '';

            // Try to get full number using intl-tel-input (region selector + digits)
            try {
                fullNumber = iti.getNumber() || '';
            } catch (e) {
                console.warn('getNumber() failed, trying alternative method:', e);
            }

            // If getNumber() returns empty, construct from region dial code and composite digits
            if (!fullNumber && composite.localNumber) {
                var countryData = iti.getSelectedCountryData();
                if (countryData && countryData.dialCode) {
                    fullNumber = '+' + countryData.dialCode + composite.localNumber;
                }
            }

            var integerNumber = toIntegerFormat(fullNumber);
            hiddenPhone.value = integerNumber;
            
            console.log('Updating phone field:', {
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

    // Update hidden phone field with integer format before form submit
    form.addEventListener('submit', function(e) {
        updateHiddenPhone();
        console.log('Form submit: Final phone value:', {
            hiddenName: hiddenPhone.name,
            hiddenValue: hiddenPhone.value
        });
    }, true);

    // Blur handlers on composite inputs
    function handleBlur() {
        updateHiddenPhone();
        validatePhone(iti, visibleInput);
    }

    areaInput.addEventListener('blur', handleBlur);
    mainInput.addEventListener('blur', handleBlur);

    // Input handlers for composite fields
    function handleCompositeInput() {
        var composite = syncCompositeToVisible();
        updateHiddenPhone();

        var wrapper = visibleInput.closest('.pf-v5-c-form-control');
        if (wrapper) {
            wrapper.classList.remove('pf-m-error');
        }
        var errorMsg = visibleInput.parentElement.querySelector('.phone-error-message');
        if (errorMsg) {
            errorMsg.style.display = 'none';
        }

        return composite;
    }

    areaInput.addEventListener('input', function () {
        var composite = handleCompositeInput();
        // Когда код города набран полностью (3 цифры) — переводим фокус на основное поле
        if (composite && composite.areaDigits && composite.areaDigits.length === 3) {
            mainInput.focus();
        }
    });

    mainInput.addEventListener('input', handleCompositeInput);

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
