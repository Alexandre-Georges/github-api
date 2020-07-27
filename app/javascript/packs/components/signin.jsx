import React, { useState } from 'react';
import PropTypes from 'prop-types';

import Paper from '@material-ui/core/Paper';
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';

const Signin = props => {
  const [username, setUsername] = useState('');
  const [token, setToken] = useState('');
  const submit = e => {
    e.preventDefault();
    props.updateCredentials(username, token);
  };
  const changeUsername = e => setUsername(e.target.value);
  const changeToken = e => setToken(e.target.value);
  return (
    <div>
      <Paper className="log-in">
        <form onSubmit={submit}>
          <a href="https://github.com/settings/tokens" target="_blank" rel="noopener">Create a token here</a>
          <TextField label="Github username" type="text" value={username} onChange={changeUsername} />
          {/* <input type="text" placeholder="Github username" value={username} onChange={changeUsername}></input> */}
          <TextField label="Github token" type="password" value={token} onChange={changeToken} />
          {/* <input type="password" placeholder="Github token" value={token} onChange={changeToken}></input> */}

          <Button type="submit">Log in</Button>
        </form>
      </Paper>
    </div>
  );
};

Signin.propTypes = {
  submit: PropTypes.func,
};

export default Signin;
