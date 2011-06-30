/*
 * ko.jqm.bindings v1.0.0
 * Copyright (c) 2011 CodeCatalyst, LLC.
 * Open source under the MIT License.
 */
(function() {
  var checkedBindingInitHandler, checkedBindingUpdateHandler, keepNative, valueBindingUpdateHandler;
  valueBindingUpdateHandler = ko.bindingHandlers['value']['update'];
  ko.bindingHandlers['value']['update'] = function(element, valueAccessor) {
    valueBindingUpdateHandler(element, valueAccessor);
    if (element.tagName === "SELECT") {
      try {
        $(element).selectmenu("refresh");
      } catch (error) {

      }
    } else if (element.type === "range") {
      try {
        $(element).slider("refresh");
      } catch (error) {

      }
    }
  };
  keepNative = ":jqmData(role='none'), :jqmData(role='nojs')";
  checkedBindingInitHandler = ko.bindingHandlers['checked']['init'];
  ko.bindingHandlers['checked']['init'] = function(element, valueAccessor) {
    var updateHandler;
    checkedBindingInitHandler(element, valueAccessor);
    updateHandler = function() {
      var allBindings, existingEntryIndex, modelValue, valueToWrite;
      if (element.type === "checkbox") {
        valueToWrite = element.checked;
      } else if ((element.type === "radio") && element.checked) {
        valueToWrite = element.value;
      } else {
        return;
      }
      modelValue = valueAccessor();
      if ((element.type === "checkbox") && (ko.utils.unwrapObservable(modelValue) instanceof Array)) {
        existingEntryIndex = ko.utils.arrayIndexOf(ko.utils.unwrapObservable(modelValue), element.value);
        if (element.checked && (existingEntryIndex < 0)) {
          return modelValue.push(element.value);
        } else if ((!element.checked) && (existingEntryIndex >= 0)) {
          return modelValue.splice(existingEntryIndex, 1);
        }
      } else if (ko.isWriteableObservable(modelValue)) {
        if (modelValue() !== valueToWrite) {
          return modelValue(valueToWrite);
        }
      } else {
        allBindings = allBindingsAccessor();
        if (allBindings["_ko_property_writers"] && allBindings["_ko_property_writers"]["checked"]) {
          return allBindings["_ko_property_writers"]["checked"](valueToWrite);
        }
      }
    };
    if (!$(element).is(keepNative)) {
      ko.utils.registerEventHandler(element, "change", updateHandler);
    }
  };
  checkedBindingUpdateHandler = ko.bindingHandlers['checked']['update'];
  ko.bindingHandlers['checked']['update'] = function(element, valueAccessor) {
    checkedBindingUpdateHandler(element, valueAccessor);
    if (element.type === "radio" || element.type === "checkbox") {
      try {
        $(element).checkboxradio("refresh");
      } catch (error) {

      }
    }
  };
}).call(this);
