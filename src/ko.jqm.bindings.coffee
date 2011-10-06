# [ko.jqm.bindings](http://github.com/CodeCatalyst/ko.jqm.bindings) v1.0.2  
# Copyright (c) 2011 [CodeCatalyst, LLC](http://www.codecatalyst.com/).  
# Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).

# Extensions to the standard (KnockoutJS)[http://knockoutjs.com/] bindingHandlers to enable two-way binding with (jQuery Mobile)[https://github.com/jquery/jquery-mobile]'s enhanced form controls.

# Written in [CoffeeScript](http://coffeescript.com/)

keepNative = ":jqmData(role='none'), :jqmData(role='nojs')"

# Execute the enhanced element's associated jQuery Mobile widget plugin's 'refresh'.
refreshElement = ( element, method ) ->
	$element = $(element)
	if not $element.is( keepNative )
		try
			$element[method]( "refresh" )
		catch error
			# intentionally ignore

# Override the default 'value' update to refresh enhanced form elements.
valueBindingUpdateHandler = ko.bindingHandlers['value']['update']
ko.bindingHandlers['value']['update'] = ( element, valueAccessor ) ->
	valueBindingUpdateHandler( element, valueAccessor )
	
	if element.tagName == "SELECT"
		refreshElement( element, "selectmenu" )
	else if element.type == "range"
		refreshElement( element, "slider" )
	return

# Override the default 'checked' init to listen for 'change' from enhanced checkboxes and radio buttons.
checkedBindingInitHandler = ko.bindingHandlers['checked']['init']
ko.bindingHandlers['checked']['init'] = ( element, valueAccessor ) ->
	checkedBindingInitHandler( element, valueAccessor )
	
	updateHandler = () ->
		if element.type == "checkbox"
			valueToWrite = element.checked
		else if ( element.type == "radio" ) and element.checked
			valueToWrite = element.value
		else
			# "checked" binding only responds to checkboxes and selected radio buttons
			return
		modelValue = valueAccessor()
		if ( element.type == "checkbox" ) and ( ko.utils.unwrapObservable( modelValue ) instanceof Array )
			# For checkboxes bound to an array, we add/remove the checkbox value to that array
			# This works for both observable and non-observable arrays
			existingEntryIndex = ko.utils.arrayIndexOf( ko.utils.unwrapObservable( modelValue ), element.value )
			if element.checked and ( existingEntryIndex < 0 )
				modelValue.push( element.value )
			else if (not element.checked) and (existingEntryIndex >= 0)
				modelValue.splice( existingEntryIndex, 1 )
		else if ko.isWriteableObservable( modelValue )
			if modelValue() != valueToWrite
				modelValue( valueToWrite )
		else
			allBindings = allBindingsAccessor()
			if allBindings["_ko_property_writers"] and allBindings["_ko_property_writers"]["checked"]
				allBindings["_ko_property_writers"]["checked"] valueToWrite
	
	# jQuery Mobile enhanced checkboxes and radio buttons dispatch 'change' rather than 'click'.
	if not $(element).is( keepNative )
		ko.utils.registerEventHandler( element, "change", updateHandler )
	return

# Override the default 'checked' update to refresh enhanced checkboxes and radio buttons.
checkedBindingUpdateHandler = ko.bindingHandlers['checked']['update']
ko.bindingHandlers['checked']['update'] = ( element, valueAccessor ) ->
	checkedBindingUpdateHandler( element, valueAccessor )
	
	if element.type == "radio" or element.type == "checkbox"
		refreshElement( element, "checkboxradio" )
	return

# Override the default 'enable' update to refresh enhanced form elements.
enableBindingUpdateHandler = ko.bindingHandlers['enable']['update']
ko.bindingHandlers['enable']['update'] = ( element, valueAccessor ) ->
	enableBindingUpdateHandler( element, valueAccessor )
	
	if element.tagName == "SELECT"
		refreshElement( element, "selectmenu" )
	else 
		switch element.type
			when "checkbox", "radio"
				refreshElement( element, "checkboxradio" )
			when "range" 
				refreshElement( element, "slider" )
	return

# Override the default 'template' update to create or refresh enhanced form elements.
templateBindingUpdateHandler = ko.bindingHandlers['template']['update']
ko.bindingHandlers['template']['update'] = ( element, valueAccessor, allBindingsAccessor, viewModel ) ->
	templateSubscriptionDomDataKey = '__ko__templateSubscriptionDomDataKey__'	
	renderTemplateSubscriptionDomDataKey = '__kojqm__renderTemplateSubscriptionDomDataKey__'
	
	previousTemplateSubscription = ko.utils.domData.get( element, renderTemplateSubscriptionDomDataKey )
	if previousTemplateSubscription?
		previousTemplateSubscription.dispose()
		
	templateBindingUpdateHandler( element, valueAccessor, allBindingsAccessor, viewModel )
	
	templateSubscription = ko.utils.domData.get( element, templateSubscriptionDomDataKey )
	
	refreshTemplate = () ->
		if element.tagName == "UL"
			refreshElement( element, "listview" )
		else
			$(element).trigger('create');
		return
	
	if templateSubscription?
		renderTemplateSubscription = templateSubscription.subscribe( refreshTemplate );
	
	ko.utils.domData.set( element, renderTemplateSubscriptionDomDataKey, renderTemplateSubscription )
	
	refreshTemplate()
	

