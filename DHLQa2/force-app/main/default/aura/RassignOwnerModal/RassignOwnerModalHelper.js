({
	fireEvent : function(component, event) {
        console.log('event fired');
		var cmpEvent = component.getEvent("ReassignedValue");
        cmpEvent.setParams({
            "valueChanged" : component.get('v.isChange')
        });
        cmpEvent.fire();
	}
})