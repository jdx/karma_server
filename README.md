Karma Server
============
[![Build Status](https://travis-ci.org/dickeyxxx/karma_server.png)](https://travis-ci.org/dickeyxxx/karma_server)

A node.js server that powers [Karma](http://dickeyxxx.github.io/karma_client).

Setup Instructions
------------------

Get the server repo and change to its directory:

```bash
git clone git@github.com:dickeyxxx/karma_server
cd karma_server
```

Install dependencies:

```bash
npm install -g nodemon
npm install
```

Start the server:

```bash
nodemon app.coffee
```

Get the client repo:

```bash
git clone git@github.com:dickeyxxx/karma_client
```

Start the local client:

```bash
grunt server
```

Go to `http://127.0.0.1:9000/?local=true` to enable connecting to your local
node instance. Otherwise it will use production.


Running the Tests
-----------------

Once you've completed the setup running the tests is simple:

```bash
npm test
```
