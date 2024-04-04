class SystemServices {
    register(serviceManager) {
        serviceManager.register("dev.rlxos.system", (source, target, method, args) => {
            console.log(`SystemServices:: (source: ${source}, target: ${target}, method: ${method}, args: ${args})`)
            if (method === "version") {
                return "0.0.1";
            }
            return "unknown method";
        });
        
    }
}