var express = require('express');
var passport = require('passport');
var Strategy = require('passport-local').Strategy;
var serveIndex = require('serve-index')
var db = require('./db');
var app = express();


const lport = 80

passport.use(new Strategy(
	function(username, password, cb) {
		db.users.findByUsername(username, function(err, user) {
			if (err) { return cb(err); }
			if (!user) { return cb(null, false); }
			if (user.password != password) { return cb(null, false); }
			return cb(null, user);
		});
	}));


passport.serializeUser(function(user, cb) {
	cb(null, user.id);
});

passport.deserializeUser(function(id, cb) {
	db.users.findById(id, function (err, user) {
		if (err) { return cb(err); }
		cb(null, user);
	});
});

app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');
app.use(require('morgan')('combined'));
app.use(require('cookie-parser')());
app.use(require('body-parser').urlencoded({ extended: true }));
app.use(require('express-session')({ secret: 'keyboard cat', resave: false, saveUninitialized: false }));
app.use(passport.initialize());
app.use(passport.session());
app.use(express.static('public'))
app.use('/files', express.static('public/files'), serveIndex('public/files', {'icons': true}))

app.get('/',
	function(req, res) {
		res.render('home', { user: req.user });
	});

app.post('/', 
	passport.authenticate('local', { failureRedirect: '/' }),
	function(req, res) {
		res.redirect('/dashboard');
	});

app.get('/login',
	function(req, res) {
		req.redirect('/');
	});

app.get('/logout',
	function(req, res) {
		req.logout();
		res.redirect('/');
	});

app.get('/dashboard',
	require('connect-ensure-login').ensureLoggedIn(),
	function(req, res) {
		res.render('shell', { user: req.user });
	});

app.listen(lport, (err) => {
	if (err) {
		return console.log('something bad happened', err)
	};

	console.log(`server is listening on ${lport}`);
});

