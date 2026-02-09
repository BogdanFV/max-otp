<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=true displayInfo=true; section>
    <#if section = "header">
        ${msg("maxOtpTitle", "Verification Code")}
    <#elseif section = "form">
        <#assign isSendFailed = (sendFailed?? && sendFailed?string("yes","no") == "yes")>
        <#assign showTimer = (resendWait?? && (resendWait > 0))>

        <#if isSendFailed>
            <#-- Send failed: show only resend options with timer -->
            <div class="${properties.kcFormGroupClass!}" style="margin-top: 1rem; text-align: center;">
                <span id="resend-timer" class="pf-c-helper-text" style="display: <#if showTimer>inline<#else>none</#if>;">
                    ${msg("maxOtpResendWait", "Resend available in")} <span id="countdown">${resendWait!0}</span> ${msg("maxOtpSeconds", "sec")}
                </span>

                <#if emailEnabled?? && emailEnabled?string("yes","no") == "yes">
                    <div id="resend-button-container" style="display: <#if showTimer>none<#else>block</#if>;">
                        <button type="button"
                                id="resend-toggle-btn"
                                class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!}"
                                onclick="document.getElementById('resend-options').style.display='flex'; document.getElementById('resend-button-container').style.display='none';">
                            ${msg("maxOtpResend", "Resend code")}
                        </button>
                    </div>
                    <div id="resend-options" style="display: none; flex-direction: column; gap: 0.5rem; margin-top: 0.5rem;">
                        <form action="${url.loginAction}" method="post">
                            <input type="hidden" name="action" value="resend_max" />
                            <input type="submit"
                                   class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!}"
                                   value="${msg("maxOtpResendMax", "Send to MAX")}" />
                        </form>
                        <form action="${url.loginAction}" method="post">
                            <input type="hidden" name="action" value="resend_email" />
                            <input type="submit"
                                   class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!}"
                                   value="${msg("maxOtpResendEmail", "Send to Email")}" />
                        </form>
                    </div>
                <#else>
                    <form id="resend-single-form" action="${url.loginAction}" method="post" style="display: <#if showTimer>none<#else>block</#if>;">
                        <input type="hidden" name="action" value="resend_max" />
                        <input type="submit"
                               class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!}"
                               value="${msg("maxOtpResend", "Resend code")}" />
                    </form>
                </#if>
            </div>

            <div class="kc-back-link-wrapper">
                <a href="${url.loginRestartFlowUrl}" class="kc-back-link">
                    Вернуться назад
                </a>
            </div>
        <#else>
            <#-- Normal flow: show OTP input form -->
            <form id="kc-otp-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">
                <div class="${properties.kcFormGroupClass!}">
                    <div class="${properties.kcLabelWrapperClass!}">
                        <label for="otp" class="${properties.kcLabelClass!}">
                            <#if currentMethod?? && currentMethod == "email">
                                ${msg("maxOtpLabelEmail", "Enter the code sent to")} ${maskedEmail!""}
                            <#else>
                                ${msg("maxOtpLabel", "Enter the code sent to")} ${maskedPhone!""}
                            </#if>
                        </label>
                    </div>
                    <div class="${properties.kcInputWrapperClass!}">
                        <input type="text"
                               id="otp"
                               name="otp"
                               class="${properties.kcInputClass!}"
                               autocomplete="one-time-code"
                               inputmode="numeric"
                               pattern="[0-9]*"
                               maxlength="${otpLength!6}"
                               autofocus
                               aria-invalid="<#if messagesPerField.existsError('otp')>true</#if>" />

                        <#if messagesPerField.existsError('otp')>
                            <span id="input-error-otp" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('otp'))?no_esc}
                            </span>
                        </#if>
                    </div>
                </div>

                <input type="hidden" name="login" value="true" />

                <div class="${properties.kcFormGroupClass!}">
                    <div id="kc-form-options" class="${properties.kcFormOptionsClass!}">
                        <div class="${properties.kcFormOptionsWrapperClass!}">
                            <#if remainingAttempts?? && (remainingAttempts < 3)>
                                <span class="pf-c-helper-text pf-m-warning">
                                    ${msg("maxOtpRemainingAttempts", "Remaining attempts:")} ${remainingAttempts}
                                </span>
                            </#if>
                        </div>
                    </div>
                </div>

                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                    <#-- Кнопка подтверждения убрана: авто-submit при вводе кода -->
                </div>

            </form>

            <script type="text/javascript">
                (function() {
                    var otpInput = document.getElementById('otp');
                    var form = document.getElementById('kc-otp-form');
                    if (!otpInput || !form) {
                        return;
                    }
                    var maxLenAttr = otpInput.getAttribute('maxlength');
                    var otpLength = parseInt(maxLenAttr || '6', 10);

                    otpInput.addEventListener('input', function() {
                        var digits = this.value.replace(/\D/g, '');
                        if (digits.length >= otpLength) {
                            otpInput.value = digits.slice(0, otpLength);
                            form.submit();
                        }
                    });
                })();
            </script>

            <div class="kc-back-link-wrapper">
                <a href="${url.loginRestartFlowUrl}" class="kc-back-link">
                    Вернуться назад
                </a>
            </div>

            <div class="${properties.kcFormGroupClass!}" style="margin-top: 1rem; text-align: center;">
                <span id="resend-timer" class="pf-c-helper-text" style="display: <#if showTimer>inline<#else>none</#if>;">
                    ${msg("maxOtpResendWait", "Resend available in")} <span id="countdown">${resendWait!0}</span> ${msg("maxOtpSeconds", "sec")}
                </span>

                <#if emailEnabled?? && emailEnabled?string("yes","no") == "yes">
                    <div id="resend-button-container" style="display: <#if showTimer>none<#else>block</#if>;">
                        <button type="button"
                                id="resend-toggle-btn"
                                class="${properties.kcButtonClass!} ${properties.kcButtonSecondaryClass!}"
                                onclick="document.getElementById('resend-options').style.display='flex'; document.getElementById('resend-button-container').style.display='none';">
                            ${msg("maxOtpResend", "Resend code")}
                        </button>
                    </div>
                    <div id="resend-options" style="display: none; flex-direction: column; gap: 0.5rem; margin-top: 0.5rem;">
                        <form action="${url.loginAction}" method="post">
                            <input type="hidden" name="action" value="resend_max" />
                            <input type="submit"
                                   class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!}"
                                   value="${msg("maxOtpResendMax", "Send to MAX")}" />
                        </form>
                        <form action="${url.loginAction}" method="post">
                            <input type="hidden" name="action" value="resend_email" />
                            <input type="submit"
                                   class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!}"
                                   value="${msg("maxOtpResendEmail", "Send to Email")}" />
                        </form>
                    </div>
                <#else>
                    <form id="resend-single-form" action="${url.loginAction}" method="post" style="display: <#if showTimer>none<#else>inline</#if>;">
                        <input type="hidden" name="action" value="resend_max" />
                        <input type="submit"
                               class="${properties.kcButtonClass!} ${properties.kcButtonSecondaryClass!}"
                               value="${msg("maxOtpResend", "Resend code")}" />
                    </form>
                </#if>
            </div>
        </#if>

        <#if resendWait?? && (resendWait > 0)>
        <script type="text/javascript">
            (function() {
                var countdown = ${resendWait};
                var countdownEl = document.getElementById('countdown');
                var timerEl = document.getElementById('resend-timer');
                var resendBtn = document.getElementById('resend-button-container');
                var resendOptions = document.getElementById('resend-options');
                var resendSingleForm = document.getElementById('resend-single-form');

                if (countdown > 0 && countdownEl) {
                    var interval = setInterval(function() {
                        countdown--;
                        if (countdown <= 0) {
                            clearInterval(interval);
                            // Hide timer, show resend button
                            if (timerEl) timerEl.style.display = 'none';
                            if (resendBtn) resendBtn.style.display = 'block';
                            if (resendSingleForm) resendSingleForm.style.display = 'block';
                        } else {
                            countdownEl.textContent = countdown;
                        }
                    }, 1000);
                }
            })();
        </script>
        </#if>
    <#elseif section = "info">
        <#if !(sendFailed?? && sendFailed?string("yes","no") == "yes")>
        <p class="instruction">
            <#if currentMethod?? && currentMethod == "email">
                ${msg("maxOtpInfoEmail", "A verification code has been sent to your email.")?no_esc}
            <#else>
                ${msg("maxOtpInfo", "A verification code has been sent to your phone via MAX messenger.")?no_esc}
            </#if>
        </p>
        </#if>
    </#if>
</@layout.registrationLayout>
