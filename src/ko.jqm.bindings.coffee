# [ko.jqm.bindings](http://github.com/CodeCatalyst/ko.jqm.bindings) v1.0.0 
# Copyright (c) 2011 [CodeCatalyst, LLC](http://www.codecatalyst.com/).  
# Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).

# Extensions to the standard (KnockoutJS)[http://knockoutjs.com/] bindingHandlers to enable two-way binding with (jQuery Mobile)[https://github.com/jquery/jquery-mobile]'s enhanced form controls.

# Written in [CoffeeScript](http://coffeescript.com/)

valueBindingUpdateHandler = ko.bindingHandlers['value']['update']
ko.bindingHandlers['value']['update'] = ( element, valueAccessor ) ->
	valueBindingUpdateHandler( element, valueAccessor )
	
	if element.tagName == "SELECT"
		try
			$(element).selectmenu( "refresh" )
		catch error
			# intentionally ignore
	else if element.type == "range"
		try
			$(element).slider( "refresh" )
		catch error
			# intentionally ignore
	return

keepNative = ":jqmData(role='none'), :jqmData(role='nojs')"

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
	
	if not $(element).is( keepNative )
		ko.utils.registerEventHandler( element, "change", updateHandler )
	return

checkedBindingUpdateHandler = ko.bindingHandlers['checked']['update']
ko.bindingHandlers['checked']['update'] = ( element, valueAccessor ) ->
	checkedBindingUpdateHandler( element, valueAccessor )
	
	if element.type == "radio" or element.type == "checkbox"
		try
			$(element).checkboxradio( "refresh" )
		catch error
			# intentionally ignore
	return
