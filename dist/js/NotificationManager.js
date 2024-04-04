class NotificationManager {
    constructor(container) {
        this.container = container;
    }

    notify(source, message) {
        const div = document.createElement("div");
        div.className = 'toast show';
        div.role = 'alter';
        div.ariaLive = 'assertive';
        div.ariaAtomic = 'true';
        div.setAttribute('data-bs-autohide', 'true');
        div.setAttribute("data-bs-delay", "10000");

        const header = document.createElement('div');
        header.className = 'toast-header';

        const title = document.createElement('strong');
        title.className = 'me-auto';
        title.innerText = source;
        header.appendChild(title);

        const close = document.createElement('button');
        close.className = 'btn-close';
        close.setAttribute('data-bs-dismiss', "toast");
        header.appendChild(close);

        div.appendChild(header);

        const body = document.createElement('div');
        body.className = 'toast-body';
        body.innerText = message;
        div.appendChild(body);

        this.container.appendChild(div);
    }

    register(serviceManager) {
        serviceManager.register('dev.rlxos.NotificationManager', (source, target, method, args) => {
            if (method === "notify") {
                this.notify(source, args);
            }
        });
    }
}