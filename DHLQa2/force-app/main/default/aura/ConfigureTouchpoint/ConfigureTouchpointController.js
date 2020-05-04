({
	doInit : function(component, event, helper) {
		var action = component.get("c.getUsers");
		 action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('user list ' + JSON.stringify(response.getReturnValue()));
                component.set('v.userList', response.getReturnValue());
            } else {
                console.log('Test fail');
            }
         }); 
         
        $A.enqueueAction(action);
	},
    
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isSave", true);
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isSave", false);
    },
    
    saveData : function(component, event, helper) {
        var data =  component.get('v.userList');
        console.log('data' + JSON.stringify(data));
         component.set("v.isSave", false);
        var action = component.get("c.saveTouchpointMapping");
        console.log('data' +  JSON.stringify(data));
        action.setParams({
            userTouchpoints : data
        });
    	
		 action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Save run successful.');
                //console.log('Return value' + response.getReturnValue());
                if(response.getReturnValue()) {
                    var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                            "title": "Success!",
                            "message": "Touchpoint Assigned.",
                            "type": "success"
                        });
                     toastEvent.fire(); 
                }else {
                    var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                            "title": "Error!",
                            "message": "Touchpoint Assignment Failed.",
                            "type": "error"
                        });
                     toastEvent.fire();
                }
                
            }else{
                console.log('Save run fail');
                var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                            "title": "Error!",
                            "message": "Touchpoint Assignment Failed.",
                            "type": "error"
                        });
                     toastEvent.fire(); 
            }
         });
        $A.enqueueAction(action);
    },
    
    handleEventChange : function(component, event, helper) {
    	var data = component.get('v.userList');
        var username = event.getParam('Username');
        console.log('username'+ event.getParam('Username'));
        console.log('touchpoints '+ event.getParam('touchpoints'));
        var touchpoints = event.getParam('touchpoints');
        var touchpointNames = touchpoints.toString();
        console.log('touch Array ' + touchpointNames);
        //data[0].Touchpoint_Name__c = event.getParam('touchpoints');
        for(var index in data) {
            console.log('data' + index);
            if(data[index].Caller_Name__c == username) {
                data[index].Touchpoint_Name__c = touchpointNames;
            }
        }
        component.set('v.userList', data);
        console.log('data ---- ' + JSON.stringify(component.get('v.userList')));
    }
})