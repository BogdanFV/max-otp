<#macro termsAcceptance>
        <div class="form-group">
            <div class="acceptance-form-container">
                <input type="checkbox" id="termsAccepted" name="termsAccepted" class="${properties.kcCheckboxInputClass!}"
                       aria-invalid="<#if messagesPerField.existsError('termsAccepted')>true</#if>"
                />
                <label for="termsAccepted" class="${properties.kcLabelClass!}">
                    Я прочитал и принимаю 
                    <a href="https://www.fa.ru/upload/medialibrary/1cc/s5nuldv0ua1ro3qn7jxdc6zfgxi9bumb/Soglasie-na-obrabotku-personalnykh-dannykh-_8_.docx" target="_blank" style="text-decoration: underline; color: #0066cc;">
                        "Согласие на обработку персональных данных"
                    </a>
                </label>
            </div>
            <#if messagesPerField.existsError('termsAccepted')>
                <div class="${properties.kcLabelWrapperClass!}">
                            <span id="input-error-terms-accepted" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('termsAccepted'))?no_esc}
                            </span>
                </div>
            </#if>
        </div>

        <!-- Popup для согласия -->
        <div id="terms-popup" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000;">
            <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 20px; border-radius: 5px; max-width: 600px; max-height: 80%; overflow-y: auto;">
                <div style="text-align: right; margin-bottom: 10px;">
                    <button onclick="hideTermsPopup()" style="background: none; border: none; font-size: 20px; cursor: pointer;">✕</button>
                </div>
                <h3>${msg("termsTitle")}</h3>
                <div style="margin-top: 15px;">
                    ${kcSanitize(msg("termsText"))?no_esc}
                </div>
            </div>
        </div>

        <script>
            function showTermsPopup() {
                document.getElementById('terms-popup').style.display = 'block';
            }
            
            function hideTermsPopup() {
                document.getElementById('terms-popup').style.display = 'none';
            }
            
            // Закрытие по клику вне popup
            document.getElementById('terms-popup').addEventListener('click', function(e) {
                if (e.target === this) {
                    hideTermsPopup();
                }
            });
        </script>
</#macro>
