<#macro group name label error="" required=false>

<div class="${properties.kcFormGroupClass}">
    <div class="${properties.kcFormGroupLabelClass}">
        <label for="${name}" class="${properties.kcFormGroupLabelClass}">
        <span class="${properties.kcFormGroupLabelTextClass}">
            ${label}
        </span>
            <#if required>
                <span class="${properties.kcInputRequiredClass}" aria-hidden="true">&#42;</span>
            </#if>
        </label>
    </div>

    <#nested>

    <div id="input-error-container-${name}">
        <#if error?has_content>
            <div class="${properties.kcFormHelperTextClass}" aria-live="polite">
                <div class="${properties.kcInputHelperTextClass}">
                    <div class="${properties.kcInputHelperTextItemClass} ${properties.kcError}" id="input-error-${name}">
                        <span class="${properties.kcInputErrorMessageClass}">
                            ${error}
                        </span>
                    </div>
                </div>
            </div>
        </#if>
    </div>
</div>

</#macro>

<#macro errorIcon error="">
  <#if error?has_content>
    <span class="${properties.kcFormControlUtilClass}">
        <span class="${properties.kcInputErrorIconStatusClass}">
          <i class="${properties.kcInputErrorIconClass}" aria-hidden="true"></i>
        </span>
    </span>
  </#if>
</#macro>

<#macro input name label value="" required=false autocomplete="off" fieldName=name error=kcSanitize(messagesPerField.get(fieldName))?no_esc autofocus=false placeholder="">
  <@group name=name label=label error=error required=required>
    <span class="${properties.kcInputClass} <#if error?has_content>${properties.kcError}</#if>">
        <input id="${name}" name="${name}" value="${value}" type="text" autocomplete="${autocomplete}" <#if autofocus>autofocus</#if>
                aria-invalid="<#if error?has_content>true</#if>" <#if placeholder?has_content>placeholder="${placeholder}"</#if>/>
        <@errorIcon error=error/>
    </span>
  </@group>
</#macro>

<#macro password name label value="" required=false forgotPassword=false fieldName=name error=kcSanitize(messagesPerField.get(fieldName))?no_esc autocomplete="off" autofocus=false placeholder="">
  <@group name=name label=label error=error required=required>
    <span class="${properties.kcInputClass} <#if error?has_content>${properties.kcError}</#if> kc-password-input-wrapper">
      <input id="${name}" name="${name}" value="${value}" type="password" autocomplete="${autocomplete}" <#if autofocus>autofocus</#if>
              aria-invalid="<#if error?has_content>true</#if>" <#if placeholder?has_content>placeholder="${placeholder}"</#if>/>
      <button class="${properties.kcFormPasswordVisibilityButtonClass} kc-password-toggle-btn" type="button" aria-label="${msg('showPassword')}"
              aria-controls="${name}" data-password-toggle
              data-icon-show="${url.resourcesPath}/img/eye.svg" data-icon-hide="${url.resourcesPath}/img/eye.svg"
              data-label-show="${msg('showPassword')}" data-label-hide="${msg('hidePassword')}">
        <img src="${url.resourcesPath}/img/eye.svg" alt="" width="24" height="24" class="kc-password-icon" />
      </button>
      <@errorIcon error=error/>
    </span>
      <#if forgotPassword>
        <div class="${properties.kcFormHelperTextClass}" aria-live="polite">
            <div class="${properties.kcInputHelperTextClass}">
                <div class="${properties.kcInputHelperTextItemClass}">
                    <span class="${properties.kcInputHelperTextItemTextClass}">
                        <a href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a>
                    </span>
                </div>
            </div>
        </div>
      </#if>
  </@group>
</#macro>

<#macro checkbox name label value=false required=false>
  <div class="${properties.kcCheckboxClass}">
    <label for="${name}" class="${properties.kcCheckboxClass}">
      <input
        class="${properties.kcCheckboxInputClass}"
        type="checkbox"
        id="${name}"
        name="${name}"
        <#if value>checked</#if>
      />
      <span class="${properties.kcCheckboxLabelClass}">${label}</span>
      <#if required>
        <span class="${properties.kcCheckboxLabelRequiredClass}" aria-hidden="true">&#42;</span>
      </#if>
    </label>
  </div>
</#macro>