class ServiceManager {
    constructor(win) {
        this.win = win;
        this.registeredObjects = {};
    }

    register(id, object) {
        console.log("ServiceManager::register registering new service", id);
        // TODO: check if already registered
        this.registeredObjects[id] = object;
    }

    handler(event, notificationManager) {
        console.log(`ServiceManager::handler event(target: ${event.data.target}, source: ${event.data.source}, method: ${event.data.method})`);
        const targetObject = this.registeredObjects[event.data.target];
        if (targetObject === undefined) {
            if (event.data.target.startsWith("metamask-")) {
                return;
            }
            notificationManager.notify('dev.rlxos.ServiceManager', `not service found for id ${event.data.target}`);
        } else {
            const data = targetObject(event.data.source, event.data.target, event.data.method, event.data.data);
            console.log(`ServiceManager::handler response(${data})`);
            event.source.postMessage({
                source: event.data.target,
                target: event.data.source,
                messageId: event.data.messageId,
                data: data,
            })
        }
    }

}
