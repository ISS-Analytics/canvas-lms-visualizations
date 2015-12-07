# Canvas LMS Class Visualizations

Feel free to clone the repo.

### Google OAuth

At the moment, we handle sign-in/registration using Google OAuth. You'd need Google Dev credentials: a `CLIENT_ID` & `CLIENT_SECRET` for this. Google has [easy to follow instructions](https://developers.google.com/gmail/api/auth/web-server) for this here.

Alternatively, you could follow this [link](https://console.developers.google.com//start/api?id=gmail&credential=client_key) to enable the Gmail API - You'd need to sign in to Gmail first. Click "Go to credentials" and fill in the necessary forms. Click `Add credentials` -> `OAuth 2.0 client ID`. The rest should be easy. Save the `CLIENT_ID` & `CLIENT_SECRET` in the config_env.rb (See `config/config_env.rb.example`).

This is a `Web application`. For development purposes, authorized origins are of the form:
- `http://localhost:9292`
- `https://canvas-viz.herokuapp.com`

And authorized redirect URIs take the form:
- `http://localhost:9292/oauth2callback_gmail`
- `https://canvas-viz.herokuapp.com/oauth2callback_gmail`

### config_env.rb

To generate `MSG_KEY` and `DB_KEY` for the config_env, simply run `rake keys_for_config` from the terminal and copy the generated keys to config_env.rb.

### Gems & DB

To get up and running on localhost, run `rake` from the terminal.
- This will install the required gems and setup the database.
- The Rakefile has additional commands to help with deployment to heroku.
