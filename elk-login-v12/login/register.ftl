<#import "template.ftl" as layout>
<#import "field.ftl" as field>
<#import "user-profile-commons.ftl" as userProfileCommons>
<#import "register-commons.ftl" as registerCommons>
<#import "password-validation.ftl" as validator>
<@layout.registrationLayout displayMessage=messagesPerField.exists('global') displayRequiredFields=true; section>
<!-- template: register.ftl -->

    <#if section = "header">
        <#if messageHeader??>
            ${kcSanitize(msg("${messageHeader}"))?no_esc}
        <#else>
            ${msg("registerTitle")}
        </#if>
    <#elseif section = "form">
        <#-- Проверяем, включена ли капча через конфигурацию -->
        <#assign captchaRequired = false>
        <#if properties.captchaEnabled?? && properties.captchaEnabled == "true">
            <#assign captchaRequired = true>
        </#if>
        
        <form id="kc-register-form" class="${properties.kcFormClass!}" action="${url.registrationAction}" method="post" novalidate="novalidate">
            <@userProfileCommons.userProfileFormFields; callback, attribute>
                <#if callback = "afterField">
                <#-- render password fields just under the username or email (if used as username) -->
                    <#if passwordRequired?? && (attribute.name == 'username' || (attribute.name == 'email' && realm.registrationEmailAsUsername))>
                        <@field.password name="password" required=true label=msg("password") autocomplete="new-password" placeholder="Пароль" />
                        <@field.password name="password-confirm" required=true label=msg("passwordConfirm") autocomplete="new-password" placeholder="Подтвердите пароль" />
                    </#if>
                </#if>
            </@userProfileCommons.userProfileFormFields>

            <@registerCommons.termsAcceptance/>

            <!-- Hidden credential field -->
            <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>

            <!-- Yandex SmartCaptcha -->
            <#if captchaRequired>
                <script src="https://smartcaptcha.yandexcloud.net/captcha.js" async defer crossorigin="anonymous"></script>
                    <div class="yandex-captcha-cover">
                        <div class="${properties.kcLabelClass!}">
                            <label class="pf-v5-c-form__label" for="yandex-captcha">
                                <span class="pf-v5-c-form__label-text">Капча</span>&nbsp;<span class="pf-v5-c-form__label-required" aria-hidden="true">&#42;</span>
                            </label>
                        </div>
                        <div id="yandex-captcha"
                                class="smart-captcha"
                                data-sitekey="${captchaSiteKey!'ysc1_f6iNWvUKAd9UI5bTT5JRm1Xw9G4pPlXx7tZuZJdKc433ce38'}"
                                data-callback="onCaptchaSuccess">
                        </div>
                        <span id="input-error-captcha" class="${properties.kcInputErrorMessageClass!}" aria-live="polite" style="display: none;">
                            Проверка не пройдена
                        </span>
                    </div>
            </#if>

            <script>
                <#if captchaRequired>
                let captchaCompleted = false;
                
                function onCaptchaSuccess(token) {
                    captchaCompleted = true;
                    console.log('Yandex captcha token received:', token);
                    const errorElement = document.getElementById('input-error-captcha');
                    if (errorElement) {
                        errorElement.style.display = 'none';
                    }
                    const inputDiv = document.querySelector('#yandex-captcha').closest('.${properties.kcInputClass!}');
                    if (inputDiv) {
                        inputDiv.classList.remove('pf-m-error');
                    }
                }
                </#if>
                
                function validateEmailDomain(email) {
                    if (!email) return true;
                    var domain = email.toLowerCase().trim();
                    var at = domain.indexOf('@');
                    if (at === -1) return true;
                    domain = domain.substring(at + 1);
                    return domain !== 'fa.ru' && !domain.endsWith('.fa.ru');
                }

                function showEmailDomainError(emailInput, show) {
                    var fieldName = emailInput.id || emailInput.name;
                    var errorContainer = document.getElementById('input-error-container-' + fieldName);
                    if (!errorContainer) return;

                    var errorElement = errorContainer.querySelector('.${properties.kcFormHelperTextClass!}[data-domain-error]');
                    if (!errorElement && show) {
                        errorElement = document.createElement('div');
                        errorElement.className = '${properties.kcFormHelperTextClass!}';
                        errorElement.setAttribute('aria-live', 'polite');
                        errorElement.setAttribute('data-domain-error', 'true');
                        errorElement.innerHTML = '<div class="${properties.kcInputHelperTextClass!}"><div class="${properties.kcInputHelperTextItemClass!} ${properties.kcError!}" id="input-error-' + fieldName + '-domain"><span class="${properties.kcInputErrorMessageClass!}">${msg("emailDomainNotAllowed")}</span></div></div>';
                        errorContainer.appendChild(errorElement);
                    }
                    if (errorElement) errorElement.style.display = show ? 'block' : 'none';

                    var inputWrapper = emailInput.closest('span.${properties.kcInputClass!}');
                    if (inputWrapper) {
                        if (show) {
                            inputWrapper.classList.add('${properties.kcError!}');
                            emailInput.setAttribute('aria-invalid', 'true');
                        } else {
                            var other = errorContainer.querySelectorAll('.${properties.kcFormHelperTextClass!}:not([data-domain-error])');
                            var hasOther = false;
                            for (var i = 0; i < other.length; i++) { if (other[i].style.display !== 'none') { hasOther = true; break; } }
                            if (!hasOther) {
                                inputWrapper.classList.remove('${properties.kcError!}');
                                emailInput.removeAttribute('aria-invalid');
                            }
                        }
                    }
                }
                
                document.addEventListener('DOMContentLoaded', function() {
                    const emailInput = document.getElementById('email') || document.getElementById('username');
                    if (!emailInput) return;
                    
                    let emailErrorShown = false;
                    
                    emailInput.addEventListener('input', function() {
                        const emailValue = this.value;
                        const isValid = validateEmailDomain(emailValue);
                        
                        if (!isValid && !emailErrorShown) {
                            showEmailDomainError(this, true);
                            emailErrorShown = true;
                        } else if (isValid && emailErrorShown) {
                            showEmailDomainError(this, false);
                            emailErrorShown = false;
                        }
                    });
                    
                    emailInput.addEventListener('blur', function() {
                        const emailValue = this.value;
                        const isValid = validateEmailDomain(emailValue);
                        
                        if (!isValid) {
                            showEmailDomainError(this, true);
                            emailErrorShown = true;
                        } else {
                            showEmailDomainError(this, false);
                            emailErrorShown = false;
                        }
                    });
                });
                
                // Валидация формы перед отправкой
                document.getElementById('kc-register-form').addEventListener('submit', function(e) {
                    <#if captchaRequired>
                    if (!captchaCompleted) {
                        e.preventDefault();
                        const errorElement = document.getElementById('input-error-captcha');
                        if (errorElement) {
                            errorElement.style.display = 'block';
                        }
                        const inputDiv = document.querySelector('#yandex-captcha').closest('.${properties.kcInputClass!}');
                        if (inputDiv) {
                            inputDiv.classList.add('pf-m-error');
                        }
                        return false;
                    }
                    </#if>
                    
                    var emailInput = document.getElementById('email') || document.getElementById('username');
                    if (emailInput) {
                        var emailValue = emailInput.value.trim();
                        if (emailValue && !validateEmailDomain(emailValue)) {
                            e.preventDefault();
                            showEmailDomainError(emailInput, true);
                            emailInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
                            emailInput.focus();
                            return false;
                        }
                    }
                });
                
                <#if captchaRequired>
                <#if message?? && message.type == 'error'>
                    console.log('Captcha error:', '${message.summary}');
                </#if>
                </#if>
            </script>

            <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doRegister")}"/>
            </div>

            <div class="${properties.kcFormGroupClass!} pf-v5-c-login__main-footer-band">
                <div id="kc-form-options" class="${properties.kcFormOptionsClass!} pf-v5-c-login__main-footer-band-item">
                    <div class="${properties.kcFormOptionsWrapperClass!}">
                        <span><a href="${url.loginUrl}">${kcSanitize(msg("backToLogin"))?no_esc}</a></span>
                    </div>
                </div>
            </div>

        </form>
        <@validator.templates/>
        <@validator.script field="password"/>
    </#if>
</@layout.registrationLayout>
