// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css";

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "./vendor/some-package.js"
//
// Alternatively, you can `npm install some-package` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import Sortable from "../vendor/sortable";

let Hooks = {};

Hooks.Sortable = {
  mounted() {
    let group = this.el.dataset.group;
    let sorter = new Sortable(this.el, {
      group: group ? group : undefined,
      animation: 150,
      delay: 100,
      dragClass: "drag-item",
      ghostClass: "drag-ghost",
      forceFallback: true,
      onEnd: (e) => {
        const itemId = e.to.id;
        // Extracts the number after "list_" in the item id, if present
        const listId = itemId.includes("list_")
          ? itemId.split("list_")[1]
          : null;

        let params = {
          old: e.oldIndex,
          new: e.newIndex,
          to: e.to.dataset,
          ...e.item.dataset,
          list_id: listId, // Now params includes the extracted list_id
        };

        this.pushEventTo(this.el, "reposition", params);
      },
    });
  },
};

Hooks.Dropdown = {
  mounted() {
    this.el.addEventListener("click", (e) => e.stopPropagation());
    document.addEventListener("click", () => this.pushEvent("close-dropdown"));
  },
  destroyed() {
    document.removeEventListener("click", () =>
      this.pushEvent("close-dropdown")
    );
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
