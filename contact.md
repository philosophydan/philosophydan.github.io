---
layout: hg-page
title: Contact
permalink: /contact/
published: true
description: "How to reach Daniel J. Singer: email, phone, and office at the University of Pennsylvania, plus a form for sending an anonymous message."
---
<dl class="contact-list">
  <div><dt>Email</dt><dd><a href="mailto:singerd@phil.upenn.edu">singerd@phil.upenn.edu</a></dd></div>
  <div><dt>Phone</dt><dd><a href="tel:+19204746437">+1 920-4Singer</a></dd></div>
  <div><dt>Office</dt><dd>461 <a href="http://www.facilities.upenn.edu/maps/locations/cohen-hall-claudia">Cohen Hall</a><br> University of Pennsylvania</dd></div>
  <div><dt>Elsewhere</dt><dd><a href="https://www.linkedin.com/in/philosophydan/">LinkedIn</a> · <a href="https://www.instagram.com/philosophydan/">Pictures of birds</a></dd></div>
</dl>

<section class="anon" id="anonymous" markdown="1">

## Send an anonymous message

Use this form to send me feedback on a class or anything else you'd like.  If you'd like a response, be sure to include your email address in the last question. Otherwise, your message will be completely anonymous.  All suggestions, comments, and constructive criticism are welcome.

<form method="POST" id="ss-form" target="_self" data-a="aHR0cHM6Ly9kb2NzLmdvb2dsZS5jb20vZm9ybXMvZC8xNXFVcUgtNGtlSFNfdC0yY3FvUXJveWc4YnVjaUxJTU1IU2VRYU9KNlZJby9mb3JtUmVzcG9uc2U/ZW1iZWRkZWQ9dHJ1ZQ==">
<noscript><p>This form needs JavaScript turned on. You can also email me instead.</p></noscript>
<ol role="list" class="ss-question-list" style="padding-left: 0;">
<div class="ss-form-question errorbox-good" role="listitem">
<div dir="auto" class="ss-item ss-item-required ss-paragraph-text"><div class="ss-form-entry">
<label class="ss-q-item-label" for="entry_2955050"><div class="ss-q-title">Type your message here.
<label for="itemView.getDomIdToLabel()" aria-label="(Required field)"></label>
<span class="ss-required-asterisk" aria-hidden="true">*</span></div>
<div class="ss-q-help ss-secondary-text" dir="auto"></div></label>
<textarea name="entry.2955050" rows="8" cols="100" class="ss-q-long" id="entry_2955050" dir="auto" aria-label="Type your message here." aria-required="true" required=""></textarea>
<div class="error-message" id="964147391_errorMessage"></div>
</div></div></div> <div class="ss-form-question errorbox-good" role="listitem">
<div dir="auto" class="ss-item ss-item-required ss-text"><div class="ss-form-entry">

<br />
<label class="ss-q-item-label" for="entry_1227771436"><div class="ss-q-title">To show you're human: what is 3 + 4?
<span class="ss-required-asterisk" aria-hidden="true">*</span></div></label>
<input type="text" inputmode="numeric" name="entry.1227771436" value="" class="ss-q-short" id="entry_1227771436" dir="auto" aria-label="To show you're human: what is 3 + 4?" aria-required="true" required="" autocomplete="off">
</div></div></div> <div class="ss-form-question errorbox-good" role="listitem">
<div dir="auto" class="ss-item  ss-text"><div class="ss-form-entry">

<br />
<label class="ss-q-item-label" for="entry_1000001"><div class="ss-q-title">Optional: Provide your email address.
</div>
<div class="ss-q-help ss-secondary-text" dir="auto"></div></label>
<input type="text" name="entry.1000001" value="" class="ss-q-short" id="entry_1000001" dir="auto" aria-label="Optional: Provide your email address." title="">
<div class="error-message" id="49145954_errorMessage"></div>
</div></div></div> <div class="errorbox-good" role="listitem">
<div dir="auto" class="ss-item  ss-section-header"><div class="ss-form-entry">
<div class="ss-section-description ss-no-ignore-whitespace"></div>
</div></div></div>
<input type="hidden" name="draftResponse" value="[,,&quot;5817155565133853645&quot;]
">
<input type="hidden" name="pageHistory" value="0">

<br />

<input type="hidden" name="fbzx" value="5817155565133853645">
<div class="hp" aria-hidden="true"><label for="hp_website">Leave this field empty</label><input type="text" id="hp_website" name="hp_website" tabindex="-1" autocomplete="off"></div>

<div class="ss-item ss-navigate"><table id="navigation-table"><tbody><tr><td class="ss-form-entry goog-inline-block" id="navigation-buttons" dir="ltr">
<input type="submit" name="submit" value="Submit Anonymous Feedback" id="ss-submit" class="jfk-button jfk-button-action ">
</td>
</tr></tbody></table></div></ol></form>

</section>

<script>
// Spam protection: the form only gets its submission address once a visitor
// starts using it, and submissions that fill the hidden field or arrive within
// a few seconds of the page loading are dropped. The "3 + 4" answer is checked
// here too, so a wrong answer shows an error on this page instead of Google's.
(function () {
  var form = document.getElementById("ss-form");
  if (!form) return;
  var check = document.getElementById("entry_1227771436");
  var loadedAt = Date.now();
  function arm() { if (!form.hasAttribute("action")) form.setAttribute("action", atob(form.dataset.a)); }
  form.addEventListener("focusin", arm);
  form.addEventListener("input", arm);
  if (check) check.addEventListener("input", function () { check.setCustomValidity(""); });
  form.addEventListener("submit", function (e) {
    var trap = document.getElementById("hp_website");
    if ((trap && trap.value) || Date.now() - loadedAt < 3000) { e.preventDefault(); return; }
    if (check && check.value.trim() !== "7") {
      e.preventDefault();
      check.setCustomValidity("That's not quite right. What is 3 + 4?");
      check.reportValidity();
      return;
    }
    arm();
  });
})();
</script>
