({
	invoke : function(component, event, helper) {
        var payload = {
            data: "some data, juste in case."
        };
		component.find("RefreshMessageChannel").publish(payload);
	}
})