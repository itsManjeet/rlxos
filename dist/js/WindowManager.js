class WindowManager {
    constructor(serviceManager) {
        this.apps = {};
        this.serviceManager = serviceManager;
        this.taskbar = document.getElementById('taskbar');
        this.taskbarContainer = document.getElementById('taskbar-container');
        this.appgrid = document.getElementById('app-grid');


    }

    start() {
        this._listAllApps();
    }

    _listAllApps() {
        fetch('/api/provider/apps')
            .then(response => {
                if (!response.ok) {
                    throw new Error('failed to get apps list');
                }
                return response.json();
            })
            .then(apps => {
                console.log('apps:', apps.data);
                for (const [id, app] of Object.entries(apps.data)) {
                    this.apps[id] = app;
                    this.appgrid.appendChild(this._createAppGridEntry(app));
                }
            })
            .catch(error => {
                console.log(error);
            });
    }

    _createTaskbarEntry(app) {
        const button = document.createElement('button');
        button.className = 'btn btn-light p-1 mx-1';

        const image = document.createElement('img');
        image.className = 'img-fluid';
        image.style.height = '27px';
        image.src = app['icon'];
        image.alt = app['title'];

        button.appendChild(image);

        return button;
    }

    _createAppGridEntry(app) {
        const div = document.createElement('div');
        div.className = 'col';
        div.setAttribute("data-bs-dismiss", "modal");
        div.setAttribute("aria-label", "Close");

        const card = document.createElement('div');
        card.className = 'card bg-transparent border-0 h-100 text-white text-center';

        const image = document.createElement('img');
        image.className = 'card-img-top';
        image.src = app['icon'];
        image.alt = app['title'];
        card.appendChild(image);

        const body = document.createElement('div');
        body.className = 'card-body';

        const label = document.createElement('p');
        label.className = 'card-text';
        label.textContent = app['title'];
        body.appendChild(label);

        card.appendChild(body);

        div.appendChild(card);

        div.addEventListener('click', () => {
            const window = this.runApp(app);
            const taskbarEntry = this._createTaskbarEntry(app);
            this.taskbarContainer.appendChild(taskbarEntry);

            taskbarEntry.onclick = () => {
                window.hide(!window.hidden);
            };

            window.onclose = (force) => {
                this.taskbarContainer.removeChild(taskbarEntry);
            };
        });

        return div;
    }


    runApp(app) {
        const window = new WinBox({
            title: app.title,
            class: ['no-full', 'no-min'],
            icon: app.icon,
            url: app.url,
            bottom: this.taskbar.offsetHeight,
            x: 'center',
            y: 'center',
        });

        window.addControl({
            index: 1,
            class: 'wb-max',
            image: '/static/img/controls/min.svg',
            click: (event, window) => {
                window.hide();
            }
        })

        this.serviceManager.register(app['id'], (source, target, method, args) => {
            window.body.lastChild.contentWindow.postMessage({
                source: source,
                target: target,
                method: method,
                data: args,
            })
        });

        setTimeout(() => {
            window.maximize();
        }, 500);


        return window;
    }
}
