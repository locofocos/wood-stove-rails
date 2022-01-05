import consumer from "channels/consumer"

consumer.subscriptions.create("TempReadingsChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Connected to the TempReadingsChannel")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log("Received TempReadingsChannel data! - " + data)
    location.reload(); // just reload the page, no need to do anything fancy. Plus there are some server-rendered charts and tables, just keep it simple.
  }
});
