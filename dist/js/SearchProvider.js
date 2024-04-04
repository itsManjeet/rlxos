class SearchProvider {
    constructor() {
    }

    search(text, notificationManager) {
        notificationManager.notify("dev.rlxos.SearchProvider", `No result found for '${text}'`);
    }
}