<#import "template.ftl" as layout>
<#import "field.ftl" as field>
<#import "buttons.ftl" as buttons>
<@layout.registrationLayout displayMessage=true displayInfo=true; section>
<!-- template: max-otp.ftl -->

    <#if section = "header">
        ${msg("maxOtpTitle")}
    <#elseif section = "form">
        <#assign isSendFailed = (sendFailed?? && sendFailed)>
        <#assign showTimer = (resendWait?? && (resendWait > 0))>

        <#if isSendFailed>
            <#-- Send failed: show only resend button with timer -->
            <div class="${properties.kcFormGroupClass!}" style="text-align: center; margin-top: 12px;">
                <#if showTimer>
                    <span id="resend-timer" class="max-otp-resend-timer">
                        ${msg("maxOtpResendWait")} <span id="countdown">${resendWait}</span> ${msg("maxOtpSeconds")}
                    </span>
                    <form id="resend-form" action="${url.loginAction}" method="post" style="display: none; margin-top: 12px;">
                        <input type="hidden" name="action" value="resend" />
                        <button type="submit"
                                class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} max-otp-resend-btn">
                            ${msg("maxOtpResend")}
                        </button>
                    </form>
                <#else>
                    <form action="${url.loginAction}" method="post">
                        <input type="hidden" name="action" value="resend" />
                        <button type="submit"
                                class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} max-otp-resend-btn">
                            ${msg("maxOtpResend")}
                        </button>
                    </form>
                </#if>
            </div>

            <div class="kc-back-link-wrapper">
                <a href="${url.loginUrl}" class="kc-back-link">
                    Вернуться назад
                </a>
            </div>

            <#if showTimer>
            <script type="text/javascript">
                (function() {
                    var countdown = ${resendWait};
                    var countdownEl = document.getElementById('countdown');
                    var timerEl = document.getElementById('resend-timer');
                    var resendForm = document.getElementById('resend-form');

                    if (countdown > 0 && countdownEl) {
                        var interval = setInterval(function() {
                            countdown--;
                            if (countdown <= 0) {
                                clearInterval(interval);
                                if (timerEl) timerEl.style.display = 'none';
                                if (resendForm) resendForm.style.display = 'block';
                            } else {
                                countdownEl.textContent = countdown;
                            }
                        }, 1000);
                    }
                })();
            </script>
            </#if>
        <#else>
            <#-- Normal flow: show OTP input form -->
            <form id="kc-otp-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">

                <div class="${properties.kcFormGroupClass!}">
                    <div class="${properties.kcLabelWrapperClass!}">
                        <label for="otp" class="${properties.kcLabelClass!}">
                            <span class="${properties.kcFormGroupLabelTextClass!}">
                                ${msg("maxOtpLabel")} ${maskedPhone!""}
                            </span>
                        </label>
                    </div>
                    <div class="${properties.kcInputWrapperClass!}">
                        <span class="${properties.kcInputClass!} <#if messagesPerField.existsError('otp')>${properties.kcError!}</#if>">
                            <input type="text"
                                   id="otp"
                                   name="otp"
                                   autocomplete="one-time-code"
                                   inputmode="numeric"
                                   pattern="[0-9]*"
                                   maxlength="${otpLength!6}"
                                   autofocus
                                   placeholder="${msg("maxOtpPlaceholder")}"
                                   aria-invalid="<#if messagesPerField.existsError('otp')>true</#if>" />
                        </span>
                    </div>
                    <#if messagesPerField.existsError('otp')>
                        <div class="${properties.kcFormHelperTextClass!}" aria-live="polite">
                            <div class="${properties.kcInputHelperTextClass!}">
                                <div class="${properties.kcInputHelperTextItemClass!} ${properties.kcError!}" id="input-error-otp">
                                    <span class="${properties.kcInputErrorMessageClass!}">
                                        ${kcSanitize(messagesPerField.get('otp'))?no_esc}
                                    </span>
                                </div>
                            </div>
                        </div>
                    </#if>
                </div>

                <#if remainingAttempts?? && (remainingAttempts < 3)>
                    <div class="${properties.kcFormGroupClass!}">
                        <div class="${properties.kcAlertClass!} pf-m-warning">
                            <span class="${properties.kcAlertTitleClass!}">
                                ${msg("maxOtpRemainingAttempts")} ${remainingAttempts}
                            </span>
                        </div>
                    </div>
                </#if>

                <input type="hidden" name="login" value="true" />

                <div class="${properties.kcFormGroupClass!}" style="text-align: center; margin-top: 12px;">
                    <#if showTimer>
                        <span id="resend-timer" class="max-otp-resend-timer">
                            ${msg("maxOtpResendWait")} <span id="countdown">${resendWait}</span> ${msg("maxOtpSeconds")}
                        </span>
                    <#else>
                        <button type="submit"
                                name="action"
                                value="resend"
                                class="${properties.kcButtonClass!} ${properties.kcButtonSecondaryClass!} max-otp-resend-btn">
                            ${msg("maxOtpResend")}
                        </button>
                    </#if>
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
                <a href="${url.loginUrl}" class="kc-back-link">
                    Вернуться назад
                </a>
            </div>

            <#if showTimer>
            <script type="text/javascript">
                (function() {
                    var countdown = ${resendWait};
                    var countdownEl = document.getElementById('countdown');
                    var timerEl = document.getElementById('resend-timer');

                    if (countdown > 0 && countdownEl) {
                        var interval = setInterval(function() {
                            countdown--;
                            if (countdown <= 0) {
                                clearInterval(interval);
                                location.reload();
                            } else {
                                countdownEl.textContent = countdown;
                            }
                        }, 1000);
                    }
                })();
            </script>
            </#if>
        </#if>
    <#elseif section = "info">
        <#if !(sendFailed?? && sendFailed)>
        <div class="max-otp-info">
            ${kcSanitize(msg("maxOtpInfo"))?no_esc}
        </div>
        </#if>
    </#if>
</@layout.registrationLayout>
