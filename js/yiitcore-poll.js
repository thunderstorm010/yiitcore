const express = require('express')

class YiitcoreAPI {

    constructor(app) {
        this.requests = []
        app.get('/yiitcore', (req, res) => {
            var auth = req.get("authorization");
            if (auth !== "D5J4Zb3IG2wJAKFretvYQsR8pCWJHryd") {
                res.sendStatus(401);
                return;
            }
            if (this.requests.length != 0) {
                var body = this.requests.join("\n");
                this.requests = [];
                res.write(body);
                return;
            }
            res.sendStatus(200);
        })
    }

    addRequestToQueue(request) {
        this.requests.push(request);
    }

    clearRequestQueue() {
        this.requests = []
    }
}

module.exports = YiitcoreAPI;