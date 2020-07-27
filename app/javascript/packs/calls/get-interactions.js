import axios from 'axios';

export default async (username, token, from, to) => {
  try {
    const response = await axios.post('/api/interactions', {
      username: username,
      token: token,
      from: from.toISOString(),
      to: to.toISOString(),
    });
    return { result: response.data };
  } catch (e) {
    return { error: e };
  }
};