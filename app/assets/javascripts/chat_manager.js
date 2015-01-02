//
// A Chat Manager interfaces with RTCC to send and receive messages from the current
// user to one specific other user.
//
// Sheffler
// Dec 2014
//

function ChatManager(rtcc, myUid, uid) {

  console.log(["newChatManager", rtcc, myUid, uid]);

  var that = this;

  // Initial state of the messages sent to/from UID
  this.messages = [
    "<br>",
    "<br>",
    "<br>",
    "<br>"
  ];

  // Emit an event that our display needs updating
  function notifyUpdate(is_received) {

    console.log(["chat:notifyUpdate"]);
    console.log(["chat:notifyUpdate", that]);

    if (typeof(that.onUpdate) == "function") {
      console.log(["chat:notifyUpdate", that, that.onUpdate]);
      that.onUpdate(is_received);
    }

  }

  // Append a 'sent' message to the message list
  function appendSent(msg) {
    x = that.messages.shift();  // pop the oldest off the front
    that.messages.push(msg + '<br>');
    notifyUpdate(false);
  }

  // Append a 'received' message to the message list
  function appendReceived(msg) {
    console.log(["chat:appendReceived"]);

    x = that.messages.shift();  // pop the oldest off the front
    that.messages.push('<i>' + msg + '</i><br>');

    console.log(["chat:appendReceived2"]);
    notifyUpdate(true);
  }

  // A chat will be rendered in a window
  this.win = null;

  // Send a message
  function sendMessage(msg) {
    appendSent(msg);
    var jdata = JSON.stringify([myUid, msg]);
    rtcc.sendDataChannelMessage(uid, jdata);
  }

  // Get the current state of the messages for display in HTML
  function getHtmlMessages() {
    // console.log(["getHtmlMessages", that.messages]);
    return that.messages;
  }

  // Exports
  that.sendMessage = sendMessage;
  that.appendReceived = appendReceived;
  that.getHtmlMessages = getHtmlMessages;

}

