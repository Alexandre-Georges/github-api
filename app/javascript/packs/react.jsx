// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React, { useState } from 'react';
import ReactDOM from 'react-dom';

import Signin from './components/signin';
import Signedin from './components/signedin';

const App = () => {
  const [username, setUsername] = useState('');
  const [token, setToken] = useState('');
  const updateCredentials = (username, token) => {
    setUsername(username);
    setToken(token);
  };
  if (!username || !token) {
    return (<Signin updateCredentials={updateCredentials}></Signin>);
  }
  return (<Signedin username={username} token={token}></Signedin>)
};

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <App />,
    document.getElementById('app'),
  )
});
