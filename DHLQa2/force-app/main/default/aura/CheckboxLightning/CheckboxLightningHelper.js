({
	fireComponentEvent : function(cmp, event, param) {
        // Get the component event by using the
        // name value from aura:registerEvent
      	var cmpEvent = cmp.getEvent("touchpointValue");
        var user = cmp.get('v.Usernam');
        console.log('Test ' + user);
        cmpEvent.setParams({
            "touchpoints" : param,
            "Username" : user
        }); 
        cmpEvent.fire();  
    }
})